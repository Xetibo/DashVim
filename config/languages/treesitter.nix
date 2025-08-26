{mkDashDefault, ...}: {
  vim.treesitter = {
    enable = mkDashDefault true;
    autotagHtml = mkDashDefault true;
    context.enable = mkDashDefault true;
  };
}
