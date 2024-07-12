{
  pkgs,
  mkDashDefault,
  ...
}: {
  vim.lazy.plugins = with pkgs.vimPlugins; {
    "overseer.nvim" = mkDashDefault {
      package = overseer-nvim;
      setupModule = "overseer";
    };
  };
}
