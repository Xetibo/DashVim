{ pkgs, ... }:
let
  # because this amazing language doesn't even have a regular parser....
  fsharp-src = pkgs.fetchFromGitHub {
    owner = "ionide";
    repo = "tree-sitter-fsharp";
    rev = "dcbd07b8860fbde39f207dbc03b36a791986cd96";
    hash = "sha256-9YSywEoXxmLbyj3K888DbrHUBG4DrGTbYesW/SeDVvs=";
  };
  treesitter-fsharp-grammar =
    (pkgs.tree-sitter.buildGrammar {
      language = "fsharp";
      version = "0.1.0";
      location = "fsharp";
      src = fsharp-src;
    }).overrideAttrs
      (prev: {
        fixupPhase = ''
          mkdir -p $out/queries/fsharp
          cp ${prev.src}/queries/*.scm $out/queries/fsharp/
        '';
      });
in
{
  plugins = {
    indent-blankline = {
      enable = true;
    };
    neogit = {
      enable = true;
    };
    trouble = {
      enable = true;
    };
    mini = {
      enable = true;
    };
    clipboard-image = {
      clipboardPackage = pkgs.wl-clipboard;
      enable = true;
    };
    refactoring = {
      enable = true;
    };
    nvim-colorizer = {
      enable = true;
    };
    flash = {
      enable = true;
      # highlightUnlabeledPhaseOneTargets = true;
    };
    noice = {
      enable = true;
      presets = {
        bottom_search = false;
        command_palette = true;
        inc_rename = true;
        long_message_to_split = true;
        lsp_doc_border = true;
      };
      # extraOptions = {
      # };
      views = {
        cmdline_popup = {
          position = {
            row = 5;
            col = "50%";
          };
          size = {
            width = 60;
            height = "auto";
          };
        };
        popupmenu = {
          relative = "editor";
          position = {
            row = 8;
            col = "50%";
          };
          size = {
            width = 60;
            height = 10;
          };
          border = {
            style = "rounded";
          };
          winhighlight = {
            Normal = "NormalFloat";
            FloatBorder = "FloatBorder";
          };
        };
      };
      notify = {
        enabled = false;
      };
      messages = {
        enabled = true;
      };
      lsp = {
        message = {
          enabled = true;
        };
        progress = {
          enabled = true;
          view = "mini";
        };
        signature.enabled = true;
      };
    };
    coverage = {
      enable = true;
    };
    project-nvim = {
      enable = true;
    };
    toggleterm = {
      enable = true;
      settings = {
        highlights = {
          FloatBorder = {
            link = "FloatBorder";
          };
        };
        direction = "float";
        float_opts = {
          border = "curved";
        };
      };
    };
    vim-surround = {
      enable = true;
    };
    spectre = {
      enable = true;
    };
    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
      };
      nixvimInjections = true;
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars ++ [
        treesitter-fsharp-grammar
      ];
    };
    diffview = {
      enable = true;
    };
    edgy = {
      enable = true;
    };
    dressing = {
      enable = true;
    };
    glow = {
      enable = true;
    };
    instant = {
      enable = true;
    };
  };
  # fsharp treesitter stuff
  extraConfigLua = ''
    do
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.fsharp = {
        install_info = {
          --url = "${fsharp-src}",
          url = 'https://github.com/ionide/tree-sitter-fsharp',
          branch = "main",
          files = {"src/scanner.c", "src/parser.c"},
          location = "fsharp",
        },
        requires_generate_from_grammar = false,
        filetype = "fsharp",
      }
    end
  '';
  extraPlugins = [
    treesitter-fsharp-grammar
  ];
}
