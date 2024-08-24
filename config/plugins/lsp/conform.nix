{ pkgs, ... }: {
  extraPackages = with pkgs; [
    prettierd
    black
    stylua
    nixfmt-classic
    yamllint
    yamlfmt
  ];
  plugins.conform-nvim = {
    enable = true;
    notifyOnError = true;
    formattersByFt = {
      html = [[ "prettierd" "prettier" ]];
      css = [[ "prettierd" "prettier" ]];
      javascript = [[ "prettierd" "prettier" ]];
      javascriptreact = [[ "prettierd" "prettier" ]];
      typescript = [[ "prettierd" "prettier" ]];
      typescriptreact = [[ "prettierd" "prettier" ]];
      python = [ "black" ];
      lua = [ "stylua" ];
      nix = [ "nixfmt" ];
      markdown = [[ "prettierd" "prettier" ]];
      yaml = [ "yamllint" "yamlfmt" ];
    };
  };
}
