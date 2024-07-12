{mkDashDefault, ...}: {
  vim.mini = mkDashDefault {
    ai.enable = true;
    comment.enable = true;
    surround.enable = true;
    basics.enable = true;
  };
}
