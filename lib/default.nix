{
  config' ? {},
  lib,
  inputs,
  pkgs,
  system,
  ...
}: let
  mkDashDefault = import ./dashDefault.nix {inherit lib;};
in
  inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    extraSpecialArgs = {inherit config' mkDashDefault system;};
    modules = [
      {_module.args = inputs // {inherit pkgs mkDashDefault system;};}
      ../config
    ];
  }
