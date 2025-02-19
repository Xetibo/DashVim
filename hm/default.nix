self: {
  lib,
  config,
  pkgs,
  options,
  dashLib,
  ...
}: let
  cfg = config.programs.dashvim;
  system = pkgs.stdenv.hostPlatform.system;
  dashvim = (
    import ../lib {
      inherit system pkgs dashLib;
      inputs = self.inputs;
      config' = cfg;
    }
  );
in {
  imports = [../modules];
  meta.maintainers = with lib.maintainers; [DashieTM];
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
  config = lib.mkIf cfg.enable (
    lib.optionalAttrs (options ? home.packages) {
      home.packages = [
        (lib.mkIf (cfg.package != null) cfg.package)
        pkgs.roslyn-ls
        pkgs.yazi
        pkgs.ripgrep
        pkgs.fd
        pkgs.zoxide
        pkgs.neovide
      ];
    }
    // lib.optionalAttrs (options ? environment.systemPackages) {
      environment.systemPackages = lib.optional (cfg.package != null) cfg.package;
    }
  );
}
