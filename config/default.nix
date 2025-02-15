{config', ...}: {
  imports = [
    ./base.nix
    ./blink.nix
    ./fzf.nix
    ./lsp.nix
    ./theme.nix
    ./treesitter.nix
    ./filetree.nix
    ./statusline.nix
    ##config'.additionalConfig
  ];
}
