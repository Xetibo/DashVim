{
  pkgs,
  neovim,
}: let
  deps = import ./dependencies.nix {inherit pkgs;};
in
  pkgs.buildEnv {
    name = "nvim";
    paths = [neovim] ++ deps;
  }
