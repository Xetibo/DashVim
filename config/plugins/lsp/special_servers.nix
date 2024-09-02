{ lib, pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    nvim-scrollbar
    overseer-nvim
    #Ionide-vim
    #(pkgs.vimUtils.buildVimPlugin {
    #  name = "Ionide-nvim";
    #  src = pkgs.fetchFromGitHub {
    #    owner = "WillEhrendreich";
    #    repo = "Ionide-nvim";
    #    rev = "525740e1f4ea6c4ce378d7bc2a860382a115b397";
    #    hash = "sha256-R75P08OPD8+IShTglrPfohHHcBKIp9FrhW3OPJLw9Bc=";
    #  };
    #})
    (pkgs.vimUtils.buildVimPlugin {
      name = "Ionide-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "DashieTM";
        repo = "Ionide-vim";
        rev = "b4d39521199f7c2e892a759e4b0bcd210d3f0736";
        hash = "sha256-PdM9sCt5TrFC+UuGDDYOC5rxPDdSh8CDq1yQo1vOnIk=";
      };
    })
    haskell-tools-nvim
    # for easy root access
    nvim-lspconfig
  ];
  # enable the plugins above
  extraConfigLua = ''
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
