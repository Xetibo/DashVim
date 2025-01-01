{ pkgs, config', ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    overseer-nvim
  ];
  plugins = {
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
        icons = { };
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
            # todo fix this
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
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
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
  };
}
