{ config', ... }: {
  imports = [ ./opts.nix ./keys.nix config'.keymaps ./plugins ./theme.nix ];
}
