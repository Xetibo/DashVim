self: { lib
      , config
      , pkgs
      , ...
      }:
let
  cfg = config.programs.dashvim;
  system = pkgs.stdenv.hostPlatform.system;
  nixvim' = self.inputs.nixvim.legacyPackages.${system};
  nixvimModule = {
    inherit pkgs;
    module = import ../config;
    extraSpecialArgs = { inputs = self.inputs; colorscheme = cfg.colorscheme; };
  };
  dashvim = nixvim'.makeNixvimWithModule nixvimModule;
in
{
  imports = [ ../modules ];
  meta.maintainers = with lib.maintainers; [ DashieTM ];
  options.programs.dashvim = with lib; {
    enable = mkEnableOption "dashvim";

    package = mkOption {
      type = with types; nullOr package;
      default = dashvim;
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
