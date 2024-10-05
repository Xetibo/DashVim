{ config', ... }:
{
  imports = [
    ./opts.nix
    ./keys.nix
    ./plugins
    ./theme.nix
    config'.additionalConfig
  ];
}
