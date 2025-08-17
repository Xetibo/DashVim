{pkgs, ...}: {
  vim.lazy.plugins = with pkgs.vimPlugins; {
    "neoscroll.nvim" = {
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
    "live-share.nvim" = {
      package = live-share-nvim;
      setupModule = "live-share";
      setupOpts = {
        port_internal = 8765;
        max_attempts = 40;
        service = "serveo.net";
      };
    };
    "toggleterm.nvim" = {
      package = toggleterm-nvim;
      setupModule = "toggleterm";
      setupOpts = {
        direction = "float";
      };
    };
    "flash.nvim" = {
      package = flash-nvim;
      setupModule = "flash";
      setupOpts = {};
    };
    "indent-blankline.nvim" = {
      package = indent-blankline-nvim;
      setupModule = "ibl";
      setupOpts = {
        exclude = {
          filetypes = ["dashboard"];
        };
      };
    };
    "yazi.nvim" = {
      package = yazi-nvim;
      setupModule = "yazi";
      setupOpts = {};
    };
  };
}
