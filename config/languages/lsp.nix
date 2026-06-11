{
  config',
  pkgs,
  lib,
  mkDashDefault,
  ...
}: let
  toolchain = import ../../lib/toolchain.nix {inherit lib pkgs;};
  pinnedTsserverPath = "${pkgs.typescript}/lib/node_modules/typescript/lib/tsserver.js";
  angularLanguageServiceRoot = "${pkgs.angular-language-server}/lib";
  angularLanguageServerCommand =
    if config'.toolchain.preferProjectTools or false
    then toolchain.bin "ngserver"
    else "${pkgs.angular-language-server}/bin/ngserver";
  typescriptRoot = "${pkgs.typescript}/lib";
  typescriptToolsWithAngular = pkgs.vimPlugins.typescript-tools-nvim.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace lua/typescript-tools/process.lua \
          --replace-fail '  local plugins_path = tsserver_provider:get_plugins_path()' '  local plugins_path = tsserver_provider:get_plugins_path()
          local plugin_probe_locations = {}
          if tsserver_provider.npm_local_path and tsserver_provider.npm_local_path:exists() then
            table.insert(plugin_probe_locations, tsserver_provider.npm_local_path:absolute())
          end
          table.insert(plugin_probe_locations, "${angularLanguageServiceRoot}")' \
          --replace-fail '  if plugins_path and #plugin_config.tsserver_plugins > 0 then' '  if plugins_path then
            table.insert(plugin_probe_locations, plugins_path:absolute())
          end

          if #plugin_config.tsserver_plugins > 0 then' \
          --replace-fail '    table.insert(self.args, plugins_path:absolute())' '    table.insert(self.args, table.concat(plugin_probe_locations, ","))'
      '';
  });
  projectTsserverPath =
    lib.generators.mkLuaInline
    /*
    lua
    */
    ''
      (function()
        local starts = {}
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname ~= nil and bufname ~= "" then
          table.insert(starts, vim.fs.dirname(bufname))
        end
        table.insert(starts, vim.fn.getcwd())

        for _, start in ipairs(starts) do
          local local_tsserver = vim.fs.find("node_modules/typescript/lib/tsserver.js", {
            path = start,
            upward = true,
          })[1]
          if local_tsserver then
            return local_tsserver
          end
        end

        return "${pinnedTsserverPath}"
      end)()
    '';
in {
  vim = {
    lazy.plugins = with pkgs.vimPlugins; {
      "ng.nvim" = mkDashDefault {
        package = ng-nvim;
      };
      "typescript-tools.nvim" = mkDashDefault {
        package = typescriptToolsWithAngular;
        setupModule = "typescript-tools";
        event = [
          {
            event = "FileType";
            pattern = "typescript";
          }
          {
            event = "FileType";
            pattern = "typescriptreact";
          }
          {
            event = "FileType";
            pattern = "javascript";
          }
          {
            event = "FileType";
            pattern = "javascriptreact";
          }
        ];
        setupOpts = {
          on_attach =
            lib.generators.mkLuaInline
            /*
            lua
            */
            ''
              function(client, bufnr)
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                if bufname == nil or bufname == "" then
                  return
                end

                local angular_root = vim.fs.find({ "angular.json", "nx.json" }, {
                  path = vim.fs.dirname(bufname),
                  upward = true,
                })[1]

                if angular_root ~= nil then
                  client.server_capabilities.referencesProvider = false
                end
              end
            '';
          settings = {
            separate_diagnostic_server = true;
            expose_as_code_action = [
              "fix_all"
              "add_missing_imports"
              "remove_unused"
              "remove_unused_imports"
              "organize_imports"
            ];
            tsserver_path =
              if config'.toolchain.preferProjectTools or false
              then lib.mkOverride 90 projectTsserverPath
              else pinnedTsserverPath;
            tsserver_locale = "en";
            tsserver_plugins = [
              "@styled/typescript-styled-plugin"
              "@effect/language-service"
              "@angular/language-service"
              "typescript-eslint-language-service"
            ];
          };
        };
      };
      "roslyn.nvim" = mkDashDefault {
        package = roslyn-nvim;
        setupModule = "roslyn";
        event = [
          {
            event = "FileType";
            pattern = "cs";
          }
        ];
        setupOpts = {
          # Search parent directories for solution files, not just cwd.
          # Fixes "LSP not attaching" when the .sln is above the opened file.
          broad_search = config'.lsp.special.roslyn.broadSearch;

          # Once a solution is selected, lock it so re-opening files doesn't
          # trigger re-selection or re-initialization (avoids needing restarts).
          lock_target = config'.lsp.special.roslyn.lockTarget;

          # Roslyn's built-in watcher can consume huge inotify counts on large repos.
          filewatching = config'.lsp.special.roslyn.filewatching;
        };
      };
    };
    extraPlugins = with pkgs.vimPlugins; {
      "easy-dotnet.nvim" = mkDashDefault {
        package = easy-dotnet-nvim;
      };
    };
    lsp = {
      presets.tailwindcss-language-server.enable = config'.lsp.tailwind.enable;
      enable = true;
      trouble = {
        enable = true;
      };
      # Ok, raf, this is awesome
      servers = {
        json = mkDashDefault {
          enable = true;
          cmd = ["${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server" "--stdio"];
          filetypes = ["json" "jsonc"];
        };
        angular = {
          enable = mkDashDefault true;
          cmd = lib.mkOverride 80 (lib.generators.mkLuaInline
            /*
            lua
            */
            ''
              function(dispatchers, config)
                local root_dir = (config and config.root_dir) or vim.fn.getcwd()
                local probe_locations = {}
                local seen = {}

                local function add_probe(path)
                  if path ~= nil and path ~= "" and not seen[path] and vim.uv.fs_stat(path) then
                    seen[path] = true
                    table.insert(probe_locations, path)
                  end
                end

                local project_node_modules = vim.fs.find("node_modules", {
                  path = root_dir,
                  upward = true,
                  type = "directory",
                })[1]

                add_probe(project_node_modules)
                add_probe("${angularLanguageServiceRoot}")
                add_probe("${typescriptRoot}")

                local function angular_core_version()
                  local package_json = vim.fs.find("package.json", {
                    path = root_dir,
                    upward = true,
                    type = "file",
                  })[1]

                  if package_json == nil then
                    return ""
                  end

                  local ok, content = pcall(vim.fn.readfile, package_json)
                  if not ok then
                    return ""
                  end

                  local parsed_ok, package = pcall(vim.json.decode, table.concat(content, "\n"))
                  if not parsed_ok or type(package) ~= "table" then
                    return ""
                  end

                  local version = (package.dependencies or {})["@angular/core"] or (package.devDependencies or {})["@angular/core"] or ""
                  return version:match("%d+%.%d+%.%d+") or ""
                end

                return vim.lsp.rpc.start({
                  "${angularLanguageServerCommand}",
                  "--stdio",
                  "--tsProbeLocations",
                  table.concat(probe_locations, ","),
                  "--ngProbeLocations",
                  table.concat(probe_locations, ","),
                  "--angularCoreVersion",
                  angular_core_version(),
                }, dispatchers)
              end
            '');
          filetypes = mkDashDefault ["htmlangular" "typescript" "typescriptreact"];
          root_markers = mkDashDefault ["angular.json" "nx.json"];
          on_attach = mkDashDefault (lib.generators.mkLuaInline
            /*
            lua
            */
            ''
              function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
                client.server_capabilities.documentOnTypeFormattingProvider = false

                local ft = vim.bo[bufnr].filetype
                if ft == "typescript" or ft == "typescriptreact" then
                  client.server_capabilities.callHierarchyProvider = false
                  client.server_capabilities.codeActionProvider = false
                  client.server_capabilities.completionProvider = false
                  client.server_capabilities.declarationProvider = false
                  client.server_capabilities.definitionProvider = false
                  client.server_capabilities.diagnosticProvider = false
                  client.server_capabilities.documentHighlightProvider = false
                  client.server_capabilities.documentLinkProvider = false
                  client.server_capabilities.documentSymbolProvider = false
                  client.server_capabilities.hoverProvider = false
                  client.server_capabilities.implementationProvider = false
                  client.server_capabilities.inlayHintProvider = false
                  client.server_capabilities.renameProvider = false
                  client.server_capabilities.selectionRangeProvider = false
                  client.server_capabilities.semanticTokensProvider = false
                  client.server_capabilities.signatureHelpProvider = false
                  client.server_capabilities.typeDefinitionProvider = false
                  client.handlers["textDocument/publishDiagnostics"] = function() end
                end
              end
            '');
        };
        # csharp = mkDashDefault {
        #   enable = true;
        #   cmd = ["${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer" "--logLevel" "Information" "--extensionLogDirectory" ".roslyn-cache" "--stdio"];
        #   filetypes = ["cs"];
        #   root_markers = ["*.csproj" ".git" "NuGet.Config"];
        # };
        # ts-ls = mkDashDefault {
        #   enable = true;
        #   cmd = ["${pkgs.typescript-language-server}/bin/typescript-language-server" "--stdio"];
        #   filetypes = ["typescript" "javascript"];
        #   root_markers = [".git" "package.json"];
        #   on_attach =
        #     lib.generators.mkLuaInline
        #     /*
        #     lua
        #     */
        #     ''
        #       function(client, bufnr)
        #         ${(import ../luaFunctions.nix).isAngular}
        #
        #         -- This shit is the most annoying thing ever
        #         client.server_capabilities.insertReplaceSupport = false
        #         local root_dir = client.config.root_dir
        #         if is_angular_project(root_dir) then
        #           client.server_capabilities.renameProvider = false
        #           client.server_capabilities.referencesProvider = false
        #         end
        #           client.server_capabilities.documentFormattingProvider = false
        #           client.server_capabilities.documentRangeFormattingProvider = false
        #           client.server_capabilities.documentOnTypeFormattingProvider = false
        #       end
        #     '';
        # };
      };
    };
    formatter.conform-nvim = {
      enable = mkDashDefault true;
      setupOpts = {
        notify_on_error = mkDashDefault true;
        formatters_by_ft = config'.formatters;
      };
    };
    languages =
      config'.lsp.lspServers
      // config'.lsp.additionalConfig;
    luaConfigRC.dashvim-roslyn-file-change-notifications = lib.nvim.dag.entryAfter ["lsp-servers"] ''
      local dashvim_roslyn_group = vim.api.nvim_create_augroup("DashVimRoslynFileChanges", { clear = true })
      local dashvim_roslyn_patterns = { "*.cs", "*.csproj", "*.sln", "*.slnx", "*.slnf", "*.props", "*.targets" }
      local dashvim_roslyn_extensions = {
        cs = true,
        csproj = true,
        sln = true,
        slnx = true,
        slnf = true,
        props = true,
        targets = true,
      }

      local function dashvim_roslyn_is_project_file(path)
        return dashvim_roslyn_extensions[vim.fn.fnamemodify(path, ":e")] == true
      end

      local function dashvim_roslyn_path_in_root(path, root)
        if root == nil or root == "" then
          return true
        end

        local normalized_path = vim.fs.normalize(path)
        local normalized_root = vim.fs.normalize(root)
        return normalized_root == "/" or normalized_path == normalized_root or vim.startswith(normalized_path, normalized_root .. "/")
      end

      local function dashvim_roslyn_notify_file_change(path, change_type)
        for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn" })) do
          if dashvim_roslyn_path_in_root(path, client.config.root_dir) then
            client:notify("workspace/didChangeWatchedFiles", {
              changes = {
                {
                  uri = vim.uri_from_fname(path),
                  type = change_type,
                },
              },
            })
          end
        end
      end

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = dashvim_roslyn_group,
        pattern = dashvim_roslyn_patterns,
        callback = function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          vim.b[args.buf].dashvim_roslyn_file_existed = path ~= "" and vim.uv.fs_stat(path) ~= nil
        end,
      })

      vim.api.nvim_create_autocmd("BufWritePost", {
        group = dashvim_roslyn_group,
        pattern = dashvim_roslyn_patterns,
        callback = function(args)
          local path = vim.api.nvim_buf_get_name(args.buf)
          if path == "" then
            return
          end

          local existed = vim.b[args.buf].dashvim_roslyn_file_existed
          vim.b[args.buf].dashvim_roslyn_file_existed = true
          dashvim_roslyn_notify_file_change(path, existed == false and 1 or 2)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = dashvim_roslyn_group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client == nil or client.name ~= "roslyn" then
            return
          end

          local path = vim.api.nvim_buf_get_name(args.buf)
          if path == "" or not dashvim_roslyn_is_project_file(path) then
            return
          end

          dashvim_roslyn_notify_file_change(path, 2)
        end,
      })
    '';
  };
}
