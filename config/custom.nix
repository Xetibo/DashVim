{
  pkgs,
  mkDashDefault,
  ...
}: {
  vim.lazy.plugins = with pkgs.vimPlugins; {
    "neoscroll.nvim" = mkDashDefault {
      package = neoscroll-nvim;
      setupModule = "neoscroll";
      setupOpts = {
        cursor_scrolls_alone = true;
        easing_function = "quadratic";
        hide_cursor = true;
        respect_scrolloff = false;
        stop_eof = true;
      };
    };
    "toggleterm.nvim" = mkDashDefault {
      package = toggleterm-nvim;
      setupModule = "toggleterm";
      setupOpts = {
        direction = "float";
        float_opts = {
          border = "rounded";
        };
        highlights = {
          FloatBorder = {
            link = "FloatBorder";
          };
        };
      };
    };
    "flash.nvim" = mkDashDefault {
      package = flash-nvim;
      setupModule = "flash";
      setupOpts = {};
    };
    "indent-blankline.nvim" = mkDashDefault {
      package = indent-blankline-nvim;
      setupModule = "ibl";
      setupOpts = {
        exclude = {
          filetypes = ["dashboard"];
        };
      };
    };
    "yazi.nvim" = mkDashDefault {
      package = yazi-nvim;
      setupModule = "yazi";
      setupOpts = {};
    };
  };
}
