{ lib, ... }:
{
  options.programs.dashvim = {
    colorscheme = lib.mkOption {
      default = "catppuccin-mocha";
      example = {
        # custom tokyo night
        base00 = "1A1B26";
        # base01 = "16161E";
        # base01 = "15161e";
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
        # base0D = "2AC3DE";
        # base0D = "A9B1D6";
        # base0D = "62A0EA";
        # base0D = "779EF1";
        base0D = "366fea";
        base0E = "BB9AF7";
        base0F = "F7768E";
      };
      type =
        with lib.types;
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
      example = [ "yourpicture" ];
      type = with lib.types; listOf str;
      description = ''
        The Ascii picture for alpha.nvim.
      '';
    };

    useDefaultCmpConfig = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = ''
        Enables Lsp Config, conform and DAP.
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
          Disabling this will remove all special servers. You can install specific ones using the additionalConfig.
        '';
      };

      lspServers = lib.mkOption {
        default = {
          bashls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
          dartls.enable = true;
          elmls.enable = true;
          dhall_lsp_server.enable = true;
          elixirls.enable = true;
          gopls.enable = true;
          # installed by haskell-tools
          # hls.enable = true;
          html.enable = true;
          htmx.enable = true;
          jsonls.enable = false;
          cssls.enable = false;
          julials = {
            enable = true;
            package = null;
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
          omnisharp.enable = true;
          pyright.enable = true;
          ruby_lsp.enable = true;
          svelte.enable = true;
          taplo.enable = true;
          sqls.enable = true;
          tinymist.enable = true;
          ts_ls.enable = true;
          yamlls.enable = true;
          zls.enable = true;
          texlab.enable = true;
          tailwindcss.enable = true;
          nixd = {
            enable = true;
          };
          #nil-ls = {
          #  enable = true;
          #  settings.formatting.command = [
          #    "nixfmt"
          #  ];
          #};
          # handled by ionide
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
                Linter = true;
                RecordStubGeneration = true;
                RecordStubGenerationBody = '''';
                ResolveNamespaces = true;
                SimplifyNameAnalyzer = true;
                UnionCaseStubGeneration = true;
                UnionCaseStubGenerationBody = '''';
                UnusedDeclarationsAnalyzer = true;
                UnusedOpensAnalyzer = true;
                UseSdkScripts = true;
                keywordsAutocomplete = true;
              };
            };
          };
        };
        example = { };
        type = with lib.types; attrsOf anything;
        description = ''
          LspServers to enable.
        '';
      };
    };

    additionalConfig = lib.mkOption {
      default = { };
      type = with lib.types; attrsOf anything;
      description = ''
        NixVim configuration to be added to DashVim.
      '';
    };
  };
}
