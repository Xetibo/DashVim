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
    # (pkgs.vimUtils.buildVimPlugin {
    #   name = "Ionide-nvim";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "DashieTM";
    #     repo = "Ionide-nvim";
    #     rev = "78f8a13d390680370f072a574017f578bf83d8f9";
    #     hash = "sha256-RAZgdEpK3UsnZc4+uuphmDrtBFukHGL+2CeAteG0dfo=";
    #   };
    # })
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
      enable = true;
      settings = {
        tools = {
          hover_actions.replace_bui = false;
        };
      };
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
