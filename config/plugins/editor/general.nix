{
  pkgs,
  config',
  ...
}: let
  treesitter-patterns = pkgs.tree-sitter.buildGrammar {
    language = "lua_patterns";
    version = "0.0.1";
    src = pkgs.fetchFromGitHub {
      owner = "OXY2DEV";
      repo = "tree-sitter-lua_patterns";
      rev = "30540892ddbb97b09837db78a97556ce563c90a9";
      hash = "sha256-5665/Phv5csnOkQlxUiqvqaVGA3ngIOY6dechqh49Cs=";
    };
    meta.homepage = "https://github.com/OXY2DEV/tree-sitter-lua_patterns";
  };
in {
  extraPlugins = with pkgs.vimPlugins; [
    overseer-nvim
    (pkgs.vimUtils.buildVimPlugin {
      name = "patterns.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "OXY2DEV";
        repo = "patterns.nvim";
        rev = "0315318de9295fbf10b660a1f3cd1cc23e655744";
        hash = "sha256-jx6HHDhoH+M8QTJFPbS5jo4QZa8nyND5qdT9h6mTT0g=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "multicursor.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "jake-stewart";
        repo = "multicursor.nvim";
        rev = "86537c3771f1989592568c9d92da2e201297867a";
        hash = "sha256-/UV+oHQ2Lr4zNiqgJM44o1RhkftrfSzf3U58loszEz8=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "endec.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "ovk";
        repo = "endec.nvim";
        rev = "949ece728ecc0cacf3c6c81bbcda186fe3fef5cf";
        hash = "sha256-Tai94rM9EnL0TRAdgiuT3Hx1NVMQJf53N7xwwRC+uKk=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "clasp.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "xzbdmw";
        repo = "clasp.nvim";
        rev = "e4361348b76684154ec88c8e0fbf5aa8dbd3e048";
        hash = "sha256-11atWGsDWAQF48rFozf26X3tU+sRNAWTz5b3QXpvsIM=";
      };
    })
  ];
  extraConfigLua =
    /*
    lua
    */
    ''
      require("multicursor-nvim").setup()
    '';
  plugins = {
    lz-n = {
      enable = true;
    };
    # this needs to be here in order to not cause errors with other plugins
    markview = {
      enable = true;
    };
    scrollview = {
      enable = true;
    };
    lsp = {
      enable = true;
    };
    lsp-format = {
      enable = true;
    };
    indent-blankline = {
      enable = true;
    };
    trouble = {
      enable = true;
    };
    mini = {
      enable = true;
      mockDevIcons = true;
      modules = {
        icons = {};
      };
    };
    clipboard-image = {
      clipboardPackage = pkgs.wl-clipboard;
      enable = true;
    };
    refactoring = {
      enable = true;
    };
    colorizer = {
      enable = true;
    };
    flash = {
      enable = true;
    };
    helpview = {
      enable = true;
    };
    image = {
      enable = true;
    };
    noice = {
      enable = true;
      settings = {
        presets = {
          bottom_search = false;
          command_palette = true;
          inc_rename = true;
          long_message_to_split = true;
          lsp_doc_border = true;
        };
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
        cmdline = {
          enabled = true;
          view = "cmdline_popup";
        };
        popupmenu = {
          enabled = true;
          backend = "nui";
        };
        lsp = {
          message = {
            enabled = true;
          };
          progress = {
            # TODO fix this
            enabled = true;
            view = "mini";
          };
          signature.enabled = true;
        };
      };
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
    nvim-surround = {
      enable = true;
    };
    spectre = {
      enable = true;
    };
    treesitter = {
      enable = true;
      settings = {
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = false;
        };
      };
      nixvimInjections = true;
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars ++ [treesitter-patterns];
    };
    treesitter-textobjects = {
      enable = true;
      swap = {
        enable = true;
        swapPrevious = {
          "<leader>sp" = {
            query = "@parameter.inner";
            desc = "Swap previous parameter";
          };
        };
        swapNext = {
          "<leader>sn" = {
            query = "@parameter.inner";
            desc = "Swap next parameter";
          };
        };
      };
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
      settings.username = config'.instantUsername;
    };
    csvview = {
      enable = true;
    };
  };
}
