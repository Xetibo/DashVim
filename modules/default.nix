{
  lib,
  config',
  ...
}: let
  ltexFiletypes = ["typst" "markdown" "gitcommit" "tex" "latex" "org" "plaintext"];
in {
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

    useDefaultKeybinds = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = ''
        Enables the default keybinds for DashVim.
        Keep in mind that regular keymaps from plugin defaults and Neovim are still active.
      '';
    };

    alphaPicture = lib.mkOption {
      default = [
        " _______       ___           _______. __    __   __   _______ "
        "|       \\     /   \\         /       ||  |  |  | |  | |   ____|"
        "|  .--.  |   /  ^  \\       |   (----`|  |__|  | |  | |  |__   "
        "|  |  |  |  /  /_\\  \\       \\   \\    |   __   | |  | |   __|  "
        "|  '--'  | /  _____  \\  .----)   |   |  |  |  | |  | |  |____ "
        "|_______/ /__/     \\__\\ |_______/    |__|  |__| |__| |_______|"
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠪⣍⣒⠒⠦⠤⠤⠤⠄⠠⡜⡐⠁⠪⡢⡀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠤⢄⠀⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠈⠛⠯⣉⠁⣐⣂⠐⠮⠥⠟⣓⣲⣾⣿⣿⣿⣶⡃⠀⠀⠈⢞⢆⠀⠀⠀⠀⠀⠀⡰⢁⠂⠄⣇⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⣠⠤⠤⠭⠷⠎⡡⠔⠒⠘⠀⢹⣿⣿⣿⣿⣿⠀⠈⠀⠀⠀⢢⢣⠀⠀⠀⠀⢀⡇⠈⠀⢰⢰⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⢸⢰⠀⠀⠀⡩⢋⣀⣤⣤⣤⣤⣤⣿⣿⠟⠿⣿⡀⠀⠀⠀⠀⠀⠆⢳⠀⠀⠀⢸⠀⠂⠀⠀⡈⡆⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⢣⢂⠀⠮⡪⠛⠉⢋⠝⠻⢿⢿⡿⢁⠔⢋⣸⠇⠀⠀⠀⠀⠀⡘⣆⢣⠀⠀⡼⠀⠀⠀⠀⡇⣇⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⡣⢲⡊⠀⠀⠀⠀⠀⡴⠃⣼⠡⢪⠔⠋⠀⠀⠀⢀⠀⠀⠀⢸⣿⡄⢆⠀⡇⠀⠀⠀⠀⠁⢸⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⢰⢡⡇⠀⠀⢀⠔⠠⠊⣰⠞⡇⢠⠃⠀⣠⣶⣿⣷⣷⣷⠄⠀⠈⡟⣷⡸⡄⡇⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⡇⣾⠀⣀⠔⣁⣤⣦⢺⣿⡆⡆⡃⠀⢨⠃⢸⣿⣿⣿⠏⠀⠠⢀⢠⣿⡇⣧⡇⠀⠀⠀⠀⠀⢸⣆⢔⡲⡆⠀          "
        "        ⠀⠀⣠⠞⠼⠧⢙⡒⣾⣿⣿⡷⡘⣟⣷⣜⡃⠀⡼⠀⠀⠷⠗⠋⠀⠀⠀⢀⡟⣿⣿⢀⠓⠀⠀⠀⠀⠀⢸⢋⠊⠀⡇⠀          "
        "        ⠘⠛⠒⠒⠉⠉⠁⡇⣿⣽⣿⡇⠈⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣠⠟⠀⣷⣿⣇⠱⡀⠀⠀⠀⡄⢀⠃⠀⡄⡇⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⡇⢸⣏⢀⣧⠀⠈⠆⠀⠀⠀⠀⠀⠀⠀⠀⡠⢊⡴⡟⠀⡼⢁⢸⡙⣠⠁⠀⠀⠀⢇⠆⠀⢀⢳⡇⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⢳⢀⣵⢸⣯⣷⣤⣀⠀⠀⠀⠀⠀⢀⣐⠮⠔⡎⠘⠀⠈⢀⢮⣿⣷⠁⠇⠠⠀⢰⠎⠀⠀⡘⣸⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⢀⠎⢬⢘⣯⠛⢻⠏⣿⣿⣶⣶⡶⠋⠉⠀⠀⢸⠀⠀⡔⠀⣪⣿⣿⢻⠀⠸⠈⡇⠛⠀⠠⢀⢃⡇⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠈⡹⡡⣪⡏⠛⠀⠀⢠⡟⢻⣿⣿⡇⠀⠀⠀⠀⢼⡆⠠⡇⢰⣿⣿⣿⣻⡄⠀⡆⠁⠀⣠⠃⠌⠼⠤⠤⡀          "
        "        ⠀⠀⠀⣀⡠⢞⣳⣽⢸⡇⠀⡇⠀⠸⠀⣼⣿⣿⡇⠀⠀⠀⠀⠈⡇⣰⠃⣶⡍⣼⣿⣏⠃⠀⠁⢠⠊⣀⣜⠤⠐⢂⢆⠇          "
        "        ⠀⠀⠈⠉⠉⠁⠀⢇⢸⡟⠀⡇⠀⡇⢸⢷⣹⣿⡇⠀⠀⠀⠀⠀⢳⡽⠃⡞⣇⣿⣧⣿⠀⠀⢸⠃⢠⠃⠀⢀⠤⢢⠞⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⢸⡀⡇⠀⠁⢠⠁⣿⠈⣿⣿⠇⠀⠀⠀⠀⠀⠀⠁⡆⡇⣾⠿⣹⣿⠀⠀⠃⡰⠃⡰⢔⣡⠞⠁⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⢇⢠⠀⠂⡌⠀⢽⠁⣟⡟⠀⠀⠀⠀⠀⠀⠀⠀⣇⢶⢹⣤⣿⠇⠀⣀⣈⠝⡱⠒⠉⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⠈⣎⡄⠀⡷⠀⢸⠀⢹⠇⠀⠀⠀⠀⠀⠀⠀⠀⠫⣼⣾⣿⢋⠤⠤⠥⢆⡞⠀⠀⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⢀⢫⣡⢸⠎⢃⢘⠀⢈⡄⠀⠀⠀⠀⠀⠀⠀⠀⢀⡽⣽⢀⡋⠉⠑⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⠘⠉⠳⡯⣇⢆⠻⣆⠈⣤⠀⠀⠀⠀⣀⡀⠤⢚⡨⠷⣝⠗⠑⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠫⣗⠳⡜⠵⠀⡍⡥⠤⠤⠤⠄⠒⠉⠀⠀⠀⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠫⡆⣇⠇⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡙⡰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀          "
        "        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣦⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀          "
      ];
      example = ["yourpicture"];
      type = with lib.types; listOf str;
      description = ''
        The Ascii picture for alpha.nvim.
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

    useDefaultCmpconfig = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = ''
        Enables Lsp config, conform and DAP.
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

    lsp = {
      useDefaultSpecialLspServers = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
        description = ''
          These are LSP servers which are installed via plugins. For example rustaceanvim for rust.
          Disabling this will remove all special servers. You can install specific ones using the additional config.
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
          angularls = {
            enable = config'.lsp.special.useAngular;
            cmd = ["ngserver"];
            # This should be handled by npm packages as mismatches can lead to breakage
            package = null;
          };
          bashls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
          dartls.enable = true;
          elmls.enable = true;
          dhall_lsp_server.enable = true;
          elixirls.enable = true;
          gopls.enable = true;
          # When using angular this is bad
          html.enable =
            if config'.lsp.special.useAngular
            then false
            else true;
          htmx.enable =
            if config'.lsp.special.useAngular
            then false
            else true;
          jsonls.enable = false;
          cssls = {
            enable = true;
            filetypes = ["css" "scss"];
          };
          julials = {
            enable = true;
            package = null;
          };
          ltex_plus = {
            enable = false;
            package = null;
            settings.ltex.enabled = ltexFiletypes;
            filetypes = ltexFiletypes;
          };
          kotlin_language_server.enable = true;
          java_language_server.enable = true;
          lua_ls.enable = true;
          gdscript = {
            enable = true;
            package = null;
          };
          terraformls.enable = true;
          # i hate this server
          #marksman.enable = true;
          nushell.enable = true;
          ocamllsp = {
            enable = true;
            package = null;
          };
          vuels = {
            enable = true;
            package = null;
          };
          pyright.enable = true;
          ruby_lsp.enable = true;
          svelte.enable = true;
          taplo.enable = true;
          gleam.enable = true;
          sqls.enable = true;
          tinymist.enable = true;
          yamlls.enable = true;
          zls.enable = true;
          texlab.enable = true;
          tailwindcss.enable = true;
          nixd = {
            enable = true;
            settings.formatting.command = [
              "alejandra"
            ];
          };
          rust_analyzer = {
            enable = true;
            # version mismatches cause issues
            # Include the right version in a flake instead
            installCargo = false;
            installRustc = false;
          };
          phpactor = {
            enable = true;
          };
          fsautocomplete = {
            enable = true;
            cmd = [
              "fsautocomplete"
              "--adaptive-lsp-server-enabled"
              "--project-graph-enabled"
              "--use-fcs-transparent-compiler"
            ];
            extraOptions = {
              init_options = {
                AutomaticWorkspaceInit = true;
              };
            };
            settings = {
              FSharp = {
                AutomaticWorkspaceInit = true;
                EnableReferenceCodeLens = true;
                ExternalAutocomplete = false;
                InterfaceStubGeneration = true;
                InterfaceStubGenerationMethodBody = '''';
                InterfaceStubGenerationObjectIdentifier = "this";
                Linter = false;
                RecordStubGeneration = true;
                RecordStubGenerationBody = '''';
                ResolveNamespaces = true;
                SimplifyNameAnalyzer = false;
                UnnecessaryParenthesesAnalyzer = false;
                UnionCaseStubGeneration = true;
                UnionCaseStubGenerationBody = '''';
                UnusedDeclarationsAnalyzer = true;
                UnusedOpensAnalyzer = true;
                UseSdkScripts = true;
                keywordsAutocomplete = true;
                excludeProjectDirectories = [
                  ".git"
                  "paket-files"
                  ".fable"
                  "packages"
                  "node_modules"
                  "tools"
                ];
              };
            };
          };
        };
        example = {};
        type = with lib.types; attrsOf anything;
        description = ''
          LspServers to enable.
        '';
      };
    };

    additionalConfig = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf anything;
      description = ''
        NixVim configuration to be added to DashVim.
      '';
    };
  };
}
