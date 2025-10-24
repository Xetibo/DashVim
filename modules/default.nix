{lib, ...}: {
  options.programs.dashvim = {
    colorscheme = lib.mkOption {
      default = "catppuccin-mocha";
      example = {
        # custom tokyo night
        base00 = "1A1B26";
        base01 = "191a25";
        base02 = "2F3549";
        base03 = "444B6A";
        base04 = "787C99";
        base05 = "A9B1D6";
        base06 = "CBCCD1";
        base07 = "D5D6DB";
        base08 = "C0CAF5";
        base09 = "A9B1D7";
        base0A = "0DB9D7";
        base0B = "9ECE6A";
        base0C = "B4F9F8";
        base0D = "366fea";
        base0E = "BB9AF7";
        base0F = "F7768E";
      };
      type = with lib.types;
        oneOf [
          str
          attrs
          path
        ];
      description = ''
        Base16 colorscheme.
        Can be an attribute set with base00 to base0F,
        a string that leads to a yaml file in base16-schemes path,
        or a path to a custom yaml file.
      '';
    };

    enableNvfDefaultKeybinds = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
        Nvf has a ton of default keybinds, this options re-enables them.
      '';
    };

    useDefaultKeybinds = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = ''
        Enables the default keybinds for DashVim.
        Keep in mind that regular keymaps from plugin defaults and Neovim are still active.
      '';
    };

    dashboardAscii = lib.mkOption {
      default = [
        " _______       ___           _______. __    __   __   _______ "
        "|       \\     /   \\         /       ||  |  |  | |  | |   ____|"
        "|  .--.  |   /  ^  \\       |   (----`|  |__|  | |  | |  |__   "
        "|  |  |  |  /  /_\\  \\       \\   \\    |   __   | |  | |   __|  "
        "|  '--'  | /  _____  \\  .----)   |   |  |  |  | |  | |  |____ "
        "|_______/ /__/     \\__\\ |_______/    |__|  |__| |__| |_______|"
        "                                                               "
      ];
      example = ["yourpicture"];
      type = with lib.types; listOf str;
      description = ''
        The Ascii picture for dashboard.nvim.
      '';
    };

    useDefaultCmpConfig = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = ''
        Enables default cmp config
      '';
    };

    instantUsername = lib.mkOption {
      default = "DashVim";
      example = "yourUserName";
      type = lib.types.str;
      description = ''
        Username for instant.nvim
      '';
    };

    agent = {
      enable = lib.mkOption {
        default = false;
        example = true;
        type = lib.types.bool;
        description = ''
          Enables codecompanion
        '';
      };
      variant = lib.mkOption {
        default = "copilot";
        example = "openai";
        type = lib.types.str;
        description = ''
          The agent type, see codecompanion for details.
        '';
      };
      key = lib.mkOption {
        default = null;
        example = null;
        type = with lib.types; nullOr anything;
        description = ''
          Key for your agent. Please don't use a plain text key, try sops-nix or agenix instead.
        '';
      };
      config = lib.mkOption {
        default = {};
        example = {};
        type = with lib.types; attrsOf anything;
        description = ''
          Config for codecompanion
        '';
      };
    };

    formatters = lib.mkOption {
      default = let
        prettier = [
          "prettierd"
          "prettier"
        ];
      in {
        json = prettier;
        htmlangular = prettier;
        html = prettier;
        css = prettier;
        scss = prettier;
        javascript = prettier;
        javascriptreact = prettier;
        typescript = prettier;
        typescriptreact = prettier;
        markdown = prettier;
        php = prettier;
        csharp = ["csharpier"];
        fsharp = ["fantomas"];
        python = ["black"];
        lua = ["stylua"];
        nix = ["alejandra"];
        yaml = [
          "yamllint"
          "yamlfmt"
        ];
      };
      example = {};
      type = with lib.types; attrsOf anything;
      description = ''
        Config for conform
      '';
    };

    lsp = {
      useDefaultSpecialLspServers = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
        description = ''
          These are LSP servers which are installed via plugins. For example rustaceanvim for rust.
          Disabling this will remove all special servers. You can install specific ones using the additionalConfig.
        '';
      };

      special = {
        useAngular = lib.mkOption {
          default = false;
          example = true;
          type = lib.types.bool;
          description = ''
            Whether to enable angular ls. Note this disables Html-ls and removes the typescript renaming function.
          '';
        };
      };

      lspServers = lib.mkOption {
        default = {
          # Defaults
          enableDAP = true;
          enableExtraDiagnostics = true;
          enableFormat = true;
          enableTreesitter = true;

          assembly = {
            enable = true;
            lsp.enable = true;
          };
          bash = {
            enable = true;
            lsp.enable = true;
          };
          clang = {
            enable = true;
            lsp.enable = true;
          };
          fsharp = {
            enable = true;
            lsp.enable = true;
          };
          csharp = {
            enable = true;
            lsp = {
              enable = true;
              servers = "omnisharp";
            };
          };
          css = {
            enable = true;
            lsp.enable = true;
          };
          tailwind = {
            enable = true;
            lsp.enable = true;
          };
          terraform = {
            enable = true;
            lsp.enable = true;
          };
          typst = {
            enable = true;
            lsp.enable = true;
          };
          ts = {
            enable = true;
            lsp.enable = false;
          };
          vala = {
            enable = true;
            lsp.enable = true;
          };
          wgsl = {
            enable = true;
            lsp.enable = true;
          };
          yaml = {
            enable = true;
            lsp.enable = true;
          };
          svelte = {
            enable = true;
            lsp.enable = true;
          };
          php = {
            enable = true;
            lsp.enable = true;
          };
          python = {
            enable = true;
            lsp.enable = true;
          };
          go = {
            enable = true;
            lsp.enable = true;
          };
          lua = {
            enable = true;
            lsp.enable = true;
          };
          # haskell = {
          #   enable = true;
          #   lsp.enable = true;
          # };
          html = {
            enable = true;
          };
          java = {
            enable = true;
            lsp.enable = true;
          };
          kotlin = {
            enable = true;
            lsp.enable = true;
          };
          markdown = {
            enable = true;
            lsp.enable = true;
          };
          nix = {
            enable = true;
            lsp.enable = true;
          };
          ruby = {
            enable = true;
            lsp.enable = true;
          };
          zig = {
            enable = true;
            lsp.enable = true;
          };
          sql = {
            enable = true;
            lsp.enable = true;
          };
          rust = {
            enable = true;
            lsp.enable = true;
            extensions.crates-nvim.enable = true;
          };
          gleam = {
            enable = true;
            lsp.enable = true;
          };
          elixir = {
            enable = true;
            lsp.enable = true;
          };
          dart = {
            enable = true;
            lsp.enable = true;
          };
        };
        example = {};
        type = with lib.types; attrsOf anything;
        description = ''
          Nvf LSP config -> vim.languages
        '';
      };

      additionalConfig = lib.mkOption {
        default = {};
        type = with lib.types; attrsOf anything;
        description = ''
          Nvf lsp configuration to be added to DashVim.
        '';
      };
    };

    additionalConfig = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf anything;
      description = ''
        Nvf configuration to be added to DashVim.
      '';
    };

    additionalLuaConfigFiles = lib.mkOption {
      default = [];
      type = with lib.types; listOf path;
      description = ''
        A list of lua files to be added to DashVim
      '';
    };
  };
}
