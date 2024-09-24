{ lib, pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    nvim-scrollbar
    overseer-nvim
    # Ionide-vim
    #(pkgs.vimUtils.buildVimPlugin {
    #  name = "Ionide-vim";
    #  src = pkgs.fetchFromGitHub {
    #    owner = "ionide";
    #    repo = "Ionide-vim";
    #    rev = "268955cc106f8328a232b160a7360cf331c0a323";
    #    hash = "sha256-tEpolSQcAt1Y/y7ZG5vW1THm8raBnXqTBTsIc1M4zVM=";
    #  };
    #})
    (pkgs.vimUtils.buildVimPlugin {
      name = "Ionide-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "DashieTM";
        repo = "Ionide-nvim";
        rev = "d035479f612e92259d87b01258a2a6d1a7d87665";
        hash = "sha256-vFZ4zsXloJ4ll0Zl/EjFHHmStpQhKhWcsx74bG1c7+4=";
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
