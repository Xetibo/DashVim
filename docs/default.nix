# with friendly help by stylix: https://github.com/danth/stylix/blob/master/docs/default.nix
{
  pkgs,
  lib,
  ...
}: let
  config' = {
    lsp.special.useAngular = false;
  };
  eval = lib.evalModules {
    modules = [
      (import ../modules {inherit lib config';})
    ];
  };
  doc = pkgs.nixosOptionsDoc {options = eval.options.programs.dashvim;};
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "dashvim-book";
    src = ./.;

    patchPhase = ''
      sed '/*Declared by:*/,/^$/d' <${doc.optionsCommonMark} >> src/conf.md
      echo "[README](README.md)\n # Options\n - [Base Config](conf.md)" >> src/SUMMARY.md
    '';

    buildPhase = ''
      ${pkgs.mdbook}/bin/mdbook build --dest-dir $out
    '';
  }
