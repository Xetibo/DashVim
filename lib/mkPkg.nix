{
  pkgs,
  mkPkgBase,
  ...
}: neovim:
pkgs.symlinkJoin {
  name = "dashvim";
  paths = [(mkPkgBase neovim)];
  nativeBuildInputs = [pkgs.makeWrapper];
  postBuild = ''
    ln -s $out/bin/nvim $out/bin/dashvim
  '';
}
