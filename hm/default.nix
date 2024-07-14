self: { lib
      , config
      , pkgs
      , ...
      }:
let
  cfg = config.programs.dashvim;
  defaultPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports= [../modules];
  meta.maintainers = with lib.maintainers; [ DashieTM ];
  options.programs.dashvim = with lib; {
    enable = mkEnableOption "dashvim";

    package = mkOption {
      type = with types; nullOr package;
      default = defaultPackage;
      defaultText = literalExpression ''
        ReSet.packages.''${pkgs.stdenv.hostPlatform.system}.default
      '';
      description = mdDoc ''
        Package to run
      '';
    };
  };
  config =
    lib.mkIf
      cfg.enable
      {
        home.packages = lib.optional (cfg.package != null) cfg.package;
      };
}
