{ pkgs, ... }: {
  plugins = {
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
    surround = {
      enable = true;
    };
    spectre = {
      enable = true;
    };
    treesitter = {
      settings.highlight.enable = true;
      grammarPackages = with pkgs.tree-sitter-grammars; [
        tree-sitter-norg
        tree-sitter-norg-meta
      ];
      enable = true;
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

}
