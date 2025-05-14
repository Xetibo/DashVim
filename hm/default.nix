self: {
  lib,
  config,
  pkgs,
  options,
  dashLib,
  ...
}: let
  config' = config.programs.dashvim;
  system = pkgs.stdenv.hostPlatform.system;
  deps = import ../lib/dependencies.nix pkgs;
  dashvim = (
    import ../lib {
      inherit system pkgs dashLib deps config';
      inputs = self.inputs;
    }
  );
in {
  imports = [
    (import ../modules {inherit lib config';})
  ];
  meta.maintainers = with lib.maintainers; [dashietm];
  options.programs.dashvim = with lib; {
    enable = mkEnableOption "dashvim";

    package = mkOption {
      type = with types; nullOr package;
      default = dashvim.build_dashvim;
      example = null;
      description = mdDoc ''
        Package to run
      '';
    };
  };
  config = lib.mkIf config'.enable (
    lib.optionalAttrs (options ? home.packages) {
      home.packages =
        [
          (lib.mkIf (config'.package != null) config'.package)
        ]
        ++ deps;
    }
    // lib.optionalAttrs (options ? environment.systemPackages) {
      environment.systemPackages = lib.optional (config'.package != null) config'.package;
    }
  );
}
