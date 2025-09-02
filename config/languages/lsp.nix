{
  config',
  pkgs,
  lib,
  mkDashDefault,
  ...
}: {
  vim = {
    lazy.plugins = with pkgs.vimPlugins; {
      "ng.nvim" = mkDashDefault {
        package = ng-nvim;
      };
      "roslyn.nvim" = mkDashDefault {
        package = roslyn-nvim;
        setupModule = "roslyn";
        setupOpts = {
          exe = "Microsoft.CodeAnalysis.LanguageServer";
        };
        ft = ["cs"];
      };
      "easy-dotnet.nvim" = mkDashDefault {
        package = easy-dotnet-nvim;
        setupModule = "easy-dotnet";
        ft = ["cs"];
      };
    };
    lsp = {
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
        };
        ts-ls = mkDashDefault {
          enable = true;
          cmd = ["${pkgs.typescript-language-server}/bin/typescript-language-server" "--stdio"];
          filetypes = ["typescript" "javascript"];
          root_markers = [".git" "package.json"];
          on_attach =
            lib.generators.mkLuaInline
            /*
            lua
            */
            ''
              function(client, bufnr)
                local function is_angular_project(root_dir)
                  if root_dir == nil then
                    return false
                  end
                  local util = require("lspconfig.util")
                  local ang = util.path.exists(util.path.join(root_dir, "angular.json"));
                  local angTemp = util.path.exists(util.path.join(root_dir, "angular-template.json"));
                  local isAngular = ang or angTemp
                  return isAngular
                end

                local root_dir = client.config.root_dir
                if is_angular_project(root_dir) then
                  client.server_capabilities.renameProvider = false
                  client.server_capabilities.referencesProvider = false
                end
                  client.server_capabilities.documentFormattingProvider = false
                  client.server_capabilities.documentRangeFormattingProvider = false
                  client.server_capabilities.documentOnTypeFormattingProvider = false
              end
            '';
        };
      };
    };
    formatter.conform-nvim = {
      enable = mkDashDefault true;
      setupOpts = {
        notify_on_error = mkDashDefault true;
        formatters_by_ft = config'.formatters;
      };
    };
    languages = config'.lsp.lspServers // config'.lsp.additionalConfig;
  };
}
