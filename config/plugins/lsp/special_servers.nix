{
  lib,
  pkgs,
  config',
  ...
}: let
  ltexFiletypes = ["typst" "markdown" "gitcommit" "tex" "latex" "org" "plaintext"];
in
  lib.mkIf config'.lsp.useDefaultSpecialLspServers {
    extraPlugins = with pkgs.vimPlugins; [
      ng-nvim
      roslyn-nvim
      image-nvim
      haskell-tools-nvim
      easy-dotnet-nvim
      gh-nvim
    ];
    # enable the plugins above
    plugins = {
      ltex-extra = {
        enable = false;
        settings = {
          server_opts = {
            filetypes = ltexFiletypes;
            settings.ltex = {
              enabled = ltexFiletypes;
            };
          };
        };
      };
      # /*
      # lua
      # */
      # ''
      #   name = "@angular/language-service",
      # ''
      typescript-tools = {
        lazyLoad.settings.ft = "typescript";
        enable = true;
        settings.settings = {
          tsserver_plugins =
            if config'.lsp.special.useAngular
            then [
              /*
              lua
              */
              {
                __raw = ''
                  name = "@angular/language-server",
                  location = "${pkgs.angular-language-server}",
                  enableForWorkspaceTypeScriptVersions = false,
                '';
              }
            ]
            else [];
        };
        settings.on_attach =
          /*
          lua
          */
          ''
            function(client, bufnr)
              local function is_angular_project(root_dir)
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
      rustaceanvim = {
        lazyLoad.settings.ft = "rust";
        # codeactions aren't nicely decorated :(
        enable = true;
        settings = {
          tools = {
            hover_actions.replace_bui = false;
          };
          float_win_config = {
            border = "rounded";
          };
        };
      };
      crates = {
        lazyLoad.settings.ft = "toml";
        enable = true;
      };
      jdtls = {
        enable = true;
        settings.cmd = [(lib.getExe pkgs.jdt-language-server)];
      };
      clangd-extensions = {
        lazyLoad.settings.event = "BufEnter";
        enable = true;
      };
      nix = {
        enable = true;
      };
    };
    extraConfigLua = ''
      local inNeovide = vim.g.neovide or false
      require("ng")
      require("litee.lib").setup()
      require("litee.gh").setup()
      if (not inNeovide) then
        require("image").setup()
      end
    '';
  }
