{
  lib,
  config',
  dashLib,
  pkgs,
  ...
}: let
  angular = dashLib.mkLsp {
    lspName = "angular-ls";
    lspPackage = pkgs.angular-language-server;
    lspFt = "typescript";
  };
in {
  vim.luaConfigRC = lib.mkIf config'.lsp.special.useAngular {
    angular-html = angular;
    typescript = angular;
  };
  vim.formatter.conform-nvim = {
    setupOpts = {
      notify_on_error = true;
      formatters_by_ft = {
        htmlangular = [
          "prettierd"
          "prettier"
        ];
        html = [
          "prettierd"
          "prettier"
        ];
        css = [
          "prettierd"
          "prettier"
        ];
        scss = [
          "prettierd"
          "prettier"
        ];
        javascript = [
          "prettierd"
          "prettier"
        ];
        javascriptreact = [
          "prettierd"
          "prettier"
        ];
        typescript = [
          "prettierd"
          "prettier"
        ];
        typescriptreact = [
          "prettierd"
          "prettier"
        ];
        fsharp = ["fantomas"];
        python = ["black"];
        lua = ["stylua"];
        nix = ["alejandra"];
        markdown = [
          "prettierd"
          "prettier"
        ];
        yaml = [
          "yamllint"
          "yamlfmt"
        ];
        php = [
          "prettierd"
          "prettier"
        ];
      };
    };
  };
  vim.lsp = {
    enable = true;
    trouble.enable = true;
  };
  vim.languages = config'.lsp.lspServers // config'.lsp.additionalConfig;
}
