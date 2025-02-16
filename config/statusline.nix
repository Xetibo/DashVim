{pkgs, ...}: {
  #vim.ui.breadcrumbs.lualine.winbar.enable = true;
  vim.lazy.plugins = with pkgs.vimPlugins; {
    "lualine.nvim" = {
      package = lualine-nvim;
      setupModule = "lualine";
      setupOpts = {
        options = {
          theme = "base16";
          disabled_filetypes = {
            statusline = ["alpha" "dashboard"];
            winbar = ["alpha" "dashboard"];
          };
        };
      };
    };
    "barbar.nvim" = {
      package = barbar-nvim;
      setupModule = "barbar";
      setupOpts = {
        auto_hide = 1;
      };
    };
  };
}
