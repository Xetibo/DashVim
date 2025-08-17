{pkgs, ...}: {
  vim.lazy.plugins = with pkgs.vimPlugins; {
    "overseer.nvim" = {
      package = overseer-nvim;
      setupModule = "overseer";
    };
  };
}
