self: {
  lib,
  config,
  pkgs,
  options,
  ...
}: let
  config' = config.programs.dashvim;
  inherit (pkgs.stdenv.hostPlatform) system;
  deps = import ../lib/dependencies.nix pkgs;
  dashvim = import ../lib {
    inherit system pkgs config' lib;
    inherit (self) inputs;
  };
in {
  imports = [
    (import ../modules {inherit lib config';})
  ];
  meta.maintainers = with lib.maintainers; [DashieTM];
  options.programs.dashvim = with lib; {
    enable = mkEnableOption "dashvim";

    package = mkOption {
      type = with types; nullOr package;
      default = dashvim.neovim;
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
          pkgs.roslyn-ls
          pkgs.yazi
          pkgs.ripgrep
          pkgs.fd
          pkgs.zoxide
          pkgs.neovide
          pkgs.gh
        ]
        ++ deps;
    }
    // lib.optionalAttrs (options ? environment.systemPackages) {
      environment.systemPackages = lib.optional (config'.package != null) config'.package;
    }
  );
}
