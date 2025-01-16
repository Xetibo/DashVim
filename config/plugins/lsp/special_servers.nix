{
  lib,
  pkgs,
  config',
  ...
}:
lib.mkIf config'.lsp.useDefaultSpecialLspServers {
  extraPlugins = with pkgs.vimPlugins; [
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
    #(pkgs.vimUtils.buildVimPlugin {
    #  name = "Ionide-nvim";
    #  src = pkgs.fetchFromGitHub {
    #    owner = "WillEhrendreich";
    #    repo = "Ionide-nvim";
    #    rev = "68e648562ff6b6454eca8b42767980ab07b7a742";
    #    hash = "sha256-4K5wNBHAs/7flVT54mU4hAfZDmxouKLrqWETJ2Zisa8=";
    #  };
    #})
    haskell-tools-nvim
    easy-dotnet-nvim
  ];
  # enable the plugins above
  plugins = {
    typescript-tools = {
      enable = true;
    };
    #seems to brick a lot rn
    rustaceanvim = {
      enable = true;
      settings = {
        tools = {
          hover_actions.replace_bui = false;
        };
      };
    };
    crates = {
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
  };
  extraConfigLua = ''
    require("easy-dotnet").setup()
  '';
}
