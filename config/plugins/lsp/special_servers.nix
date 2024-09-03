{ lib, pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    nvim-scrollbar
    overseer-nvim
    # Ionide-vim
    (pkgs.vimUtils.buildVimPlugin {
      name = "Ionide-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "DashieTM";
        repo = "Ionide-nvim";
        rev = "87f6fe9c2723f0de7e2eaa402cc4504ea4725279";
        hash = "sha256-8saOv7gcWh/TxQw3ItQkwBLsHtMGeNBCYWnXJRddoeo=";
      };
    })
    haskell-tools-nvim
  ];
  # enable the plugins above
  extraConfigLua = ''
    --require("ionide").setup({})
    require("scrollbar").setup()
    require("scrollbar.handlers.search").setup()
  '';
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
      cmd = [ (lib.getExe pkgs.jdt-language-server) ];
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
