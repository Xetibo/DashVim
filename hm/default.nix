self: { lib
      , config
      , pkgs
      , ...
      }:
let
  cfg = config.programs.dashvim;
  system = pkgs.stdenv.hostPlatform.system;
  dashvim = (import ../lib { inherit system pkgs; inputs = self.inputs; colorscheme = cfg.colorscheme; });
in
{
  imports = [ ../modules ];
  meta.maintainers = with lib.maintainers; [ DashieTM ];
  options.programs.dashvim = with lib; {
    enable = mkEnableOption "dashvim";

    package = mkOption {
      type = with types; nullOr package;
      default = dashvim.build_dashvim;
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
