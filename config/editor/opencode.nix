{
  pkgs,
  lib,
  config',
  mkDashDefault,
  ...
}: let
  opencode-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "opencode-nvim";
    version = "0.1.0";
    src = ./opencode;
    doCheck = false;
  };
in {
  vim = {
    lazy.plugins = {
      "opencode-nvim" = mkDashDefault {
        package = opencode-nvim;
        setupModule = "opencode";
        setupOpts = {};
      };
    };
  };
}
