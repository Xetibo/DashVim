{ config, ... }: {
  globals = {
    fileencoding = "utf-8";
    number = true;
    showmode = true;
    spelllang = "en_us";
    shell = "fish";
    relativenumber = false;
    scrolloff = 5;
    scrolljump = 5;
    wrap = false;
    mapleader = " ";
    gitblame_enabled = false;
    clear_background = true;
  };

  opts = {
    foldenable = false;
    foldmethod = "manual";
    termguicolors = true;
    number = true;
    shell = "fish";
  };

  colorschemes = {
    base16 = {
      settings = {
        telescope = true;
        ts_rainbow = true;
        telescope_borders = true;
        cmp = true;
        dapui = true;
        illuminate = true;
        lsp_semantic = true;
        mini_completion = true;
        notify = true;
      };
    };
    catppuccin.settings = {
      disable_underline = true;
      flavour = "mocha";
      integrations = {
        navic = {
          enabled = true;
        };
        neotest = true;
        neotree = true;
        noice = true;
        semantic_tokens = true;
        treesitter_context = true;
        which_key = true;
        aerial = true;
        alpha = true;
        cmp = true;
        dashboard = true;
        flash = true;
        gitsigns = true;
        headlines = true;
        illuminate = true;
        indent_blankline = true;
        leap = true;
        lsp_trouble = true;
        mason = true;
        markdown = true;
        native_lsp = {
          enabled = true;
          underlines = {
            errors = "undercurl";
            hints = "undercurl";
            warnings = "undercurl";
            information = "undercurl";
          };
        };
        telescope = false;
        mini = {
          enabled = true;
          indentscope_color = "";
        };
        notify = false;
        nvimtree = true;
        treesitter = true;
        barbar = true;
        toggleterm = true;
      };
      styles = {
        booleans = [
          "bold"
          "italic"
        ];
        conditionals = [
          "bold"
        ];
      };
      # term_colors = true;
    };
  } // config.programs.dashvim.colorscheme;

  clipboard.register = "unnamedplus";
  autoGroups = {
    custom_theme = { };
    highlight_yank = { };
  };
  autoCmd = [
    {
      desc = "fix theme";
      event = [ "ColorScheme" "VimEnter" ];
      group = "custom_theme";
      pattern = "*";
      callback = {
        __raw = ''function()
          vim.cmd("highlight  FloatBorder  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrent  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentADDED  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentERROR guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentCHANGED  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentDELETED  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentINFO  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentHINT  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentIndex  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentPin  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentSign  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentWarn  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentTarget  guibg=nil")
          vim.cmd("highlight  BufferDefaultCurrentMod  guibg=nil")

          vim.cmd("highlight  Pmenu  guibg=nil")
          vim.cmd("highlight  NormalFloat  guibg=nil")
        end'';
      };
    }
    {
      desc = "yank highlight";
      event = [ "TextYankPost" ];
      group = "highlight_yank";
      pattern = "*";
      callback = {
        __raw = ''function()
          vim.highlight.on_yank()
        end'';
      };
    }
  ];
}
