{ lib, pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [
    Ionide-vim
  ];
  plugins = {
    typescript-tools = {
      enable = true;
    };
    rustaceanvim = {
      enable = true;
    };
    crates-nvim = {
      enable = true;
    };
    nvim-jdtls = {
      enable = true;
      cmd = [
        (lib.getExe pkgs.jdt-language-server)
      ];
    };
    clangd-extensions = {
      enable = true;
    };
    nix = {
      enable = true;
    };
    nix-develop = {
      enable = true;
    };
  };
}
