{
  lib,
  pkgs,
  config',
  ...
}:
lib.mkIf config'.lsp.useDefaultSpecialLspServers {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-scrollbar
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
        rev = "d6449c83f9647f39a0c64676ecf9f1f788a13a66";
        hash = "sha256-dVNU3NSGCLWk4/mw2P+bDTc5TnAQTztq+ATbYmq3MGc=";
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
    #seems to brick a lot rn
    rustaceanvim = {
      enable = false;
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
  };
}
