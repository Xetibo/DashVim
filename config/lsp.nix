{
  dashLib,
  pkgs,
  ...
}: let
  fsharp = dashLib.mkLsp {
    lspName = "fsautocomplete";
    lspPackage = pkgs.fsautocomplete;
    lspFt = "fsharp";
    formatterPkg = pkgs.fantomas;
    formatterCommand = "fantomas";
    formatterPreferLsp = "fallback";
    adapterName = "corecrl";
    adapterCommand = "${pkgs.netcoredbg}/bin/netcoredbg";
    adapterArgs = ["--interpreter=vscode"];
    pickerFn =
      /*
      lua
      */
      ''
        function()
            return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end
      '';
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
