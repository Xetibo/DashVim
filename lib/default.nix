{
  config' ? {},
  lib,
  inputs,
  pkgs,
  ...
}: let
  mkDashDefault = import ./dashDefault.nix {inherit lib;};
in
  inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    extraSpecialArgs = {inherit config' mkDashDefault;};
    modules = [
      {_module.args = inputs // {inherit pkgs mkDashDefault;};}
      ../config
    ];
  }
