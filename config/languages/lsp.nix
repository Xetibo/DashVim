{
  config',
  pkgs,
  lib,
  mkDashDefault,
  ...
}: let
  pinnedTsserverPath = "${pkgs.typescript}/lib/node_modules/typescript/lib/tsserver.js";
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
        package = typescript-tools-nvim;
        setupModule = "typescript-tools";
        event = [
          {
            event = "FileType";
            pattern = "typescript";
          }
          {
            event = "FileType";
            pattern = "html";
          }
          {
            event = "FileType";
            pattern = "htmlangular";
          }
        ];
        setupOpts = {
          settings = {
            seperate_diagnostic_server = true;
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
          broad_search = true;

          # Once a solution is selected, lock it so re-opening files doesn't
          # trigger re-selection or re-initialization (avoids needing restarts).
          lock_target = true;

          # Let roslyn own file watching instead of neovim competing with it.
          # Switch to "off" if you notice performance issues.
          filewatching = "roslyn";
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
        angular = mkDashDefault {
          enable = true;
          cmd = ["${pkgs.angular-language-server}/bin/ngserver" "--stdio"];
          filetypes = ["htmlangular" "typescript" "html"];
          root_markers = [".git" "package.json"];
          on_attach =
            lib.generators.mkLuaInline
            /*
            lua
            */
            ''
              function(client, bufnr)
                -- This shit is the most annoying thing ever
                client.server_capabilities.insertReplaceSupport = false
                client.server_capabilities.renameProvider = false
                client.server_capabilities.referencesProvider = false
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
                client.server_capabilities.documentOnTypeFormattingProvider = false
              end
            '';
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
  };
}
