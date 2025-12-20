{
  pkgs,
  neovim,
  system,
  inputs,
}: let
  deps = import ./dependencies.nix {inherit pkgs system inputs;};
in
  pkgs.buildEnv {
    name = "nvim";
    paths = [neovim] ++ deps;
  }
