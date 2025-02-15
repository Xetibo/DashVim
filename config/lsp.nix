{...}: {
  vim.languages = {
    enableLSP = true;
    enableTreesitter = true;
    enableFormat = true;
    assembly = {
      enable = true;
      lsp.enable = true;
    };
    bash = {
      enable = true;
      lsp.enable = true;
    };
    clang = {
      enable = true;
      lsp.enable = true;
    };
    css = {
      enable = true;
      lsp.enable = true;
    };
    rust = {
      enable = true;
      lsp.enable = true;
    };
    # TODO config
  };
}
