{mkDashDefault, ...}: {
  vim.treesitter = mkDashDefault {
    enable = true;
    autotagHtml = true;
    context.enable = true;
  };
}
