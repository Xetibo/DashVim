{config', ...}: {
  imports = [
    ./autocmds.nix
    ./base.nix
    ./custom.nix
    ./editor
    ./keybinds.nix
    ./languages
    ./theme.nix
    config'.additionalConfig
  ];
}
