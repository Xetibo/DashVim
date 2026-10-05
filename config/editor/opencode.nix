{
  pkgs,
  lib,
  config',
  mkDashDefault,
  ...
}: let
  opencodeEnabled = !(config' ? opencode) || config'.opencode.enable;
  opencode-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "opencode-nvim";
    version = "0.1.0";
    src = ./opencode;
    doCheck = false;
  };
in
  lib.mkIf (opencodeEnabled || config'.agent.enable) {
    vim = {
      lazy.plugins = {
        "opencode-nvim" = mkDashDefault ({
            package = opencode-nvim;
          }
          // lib.optionalAttrs opencodeEnabled {
            setupModule = "opencode";
            setupOpts.default_model_mode = config'.opencode.modelMode;
          });
      };
    };
  }
