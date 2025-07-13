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
      (pkgs.vimUtils.buildVimPlugin {
        name = "ng";
        src = pkgs.fetchFromGitHub {
          owner = "joeveiga";
          repo = "ng.nvim";
          rev = "38af07e77f066e2d6e3f74d966816662075ff4cd";
          hash = "sha256-Dh7RUB7JfurQFtl0UGANs8Tc38IaEum+i0ghN9iCsQk=";
        };
      })
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
      typescript-tools = {
        lazyLoad.settings.ft = "typescript";
        enable = true;
        settings.on_attach =
          /*
          lua
          */
          ''
            function(client, bufnr)
              local function is_angular_project(root_dir)
                local util = require("lspconfig.util")
                return util.path.exists(util.path.join(root_dir, "angular.json"))
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
        enable = false;
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
      require("easy-dotnet").setup()
      require("roslyn").setup({
        exe = 'Microsoft.CodeAnalysis.LanguageServer',
      })
      require("ng")
      require("litee.lib").setup()
      require("litee.gh").setup()
      if (not inNeovide) then
        require("image").setup()
      end
    '';
  }
