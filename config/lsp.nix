{
  dashLib,
  pkgs,
  ...
}: let
  fsharp = dashLib.mkLsp {
    name = "fsautocomplete";
    package = pkgs.fsautocomplete;
    ft = "fsharp";
    formatterPkg = pkgs.fantomas;
    formatterCommand = "fantomas";
    formatterPreferLsp = "fallback";
  };
in {
  vim.lazy.plugins = with pkgs.vimPlugins; {
    "conform.nvim" = {
      package = conform-nvim;

      setupModule = "conform";
      setupOpts = {};
    };
  };
  vim.luaConfigRC.fsharp = fsharp;
  vim.lsp = {
    trouble.enable = true;
  };
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
