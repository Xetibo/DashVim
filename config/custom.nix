{pkgs, ...}: {
  vim.lazy.plugins = with pkgs.vimPlugins; {
    neogit = {
      package = neogit;

      setupModule = "neogit";
      setupOpts = {};

      after = "print('test')";
    };
    "toggleterm.nvim" = {
      package = toggleterm-nvim;
      setupModule = "toggleterm";
      setupOpts = {};
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
