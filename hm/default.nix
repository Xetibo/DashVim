inputs: {
  lib,
  config,
  pkgs,
  stable,
  options,
  ...
}: let
  config' = config.programs.dashvim;
  inherit (pkgs.stdenv.hostPlatform) system;
  deps = import ../lib/dependencies.nix {
    inherit pkgs stable system inputs;
    enableOpencode = config'.opencode.enable;
  };
  dashvim = import ../lib {
    inherit system pkgs config' lib stable;
    inherit inputs;
  };
  mkPkgBase = neovim:
    import ../lib/env.nix {
      inherit pkgs system neovim inputs;
    };
  mkPkg = import ../lib/mkPkg.nix {inherit pkgs mkPkgBase;};

  # Generate opencode theme from base16 colorscheme
  base16Lib = pkgs.callPackage inputs.base16.lib {};
  conf_scheme = config'.colorscheme;
  parsedBase =
    if builtins.isAttrs conf_scheme
    then conf_scheme
    else "${pkgs.base16-schemes}/share/themes/${conf_scheme}.yaml";
  accentColor =
    if config'.accentColor != null
    then config'.accentColor
    else parsedBase.base0D;
  parsed = parsedBase // {base0D = accentColor;};
  scheme = base16Lib.mkSchemeAttrs parsed;

  opencodeTheme = builtins.toJSON {
    "$schema" = "https://opencode.ai/theme.json";
    defs = {
      base00 = "#${scheme.base00}";
      base01 = "#${scheme.base01}";
      base02 = "#${scheme.base02}";
      base03 = "#${scheme.base03}";
      base04 = "#${scheme.base04}";
      base05 = "#${scheme.base05}";
      base06 = "#${scheme.base06}";
      base07 = "#${scheme.base07}";
      base08 = "#${scheme.base08}";
      base09 = "#${scheme.base09}";
      base0A = "#${scheme.base0A}";
      base0B = "#${scheme.base0B}";
      base0C = "#${scheme.base0C}";
      base0D = "#${scheme.base0D}";
      base0E = "#${scheme.base0E}";
      base0F = "#${scheme.base0F}";
    };
    theme = {
      primary = "base0D";
      secondary = "base0E";
      accent = "base0C";
      error = "base08";
      warning = "base09";
      success = "base0B";
      info = "base0D";
      text = "base05";
      textMuted = "base03";
      background = "none";
      backgroundPanel = "none";
      backgroundElement = "none";
      border = "base02";
      borderActive = "base03";
      borderSubtle = "base02";
      diffAdded = "base0B";
      diffRemoved = "base08";
      diffContext = "base03";
      diffHunkHeader = "base03";
      diffHighlightAdded = "base0B";
      diffHighlightRemoved = "base08";
      diffAddedBg = "none";
      diffRemovedBg = "none";
      diffContextBg = "none";
      diffLineNumber = "base03";
      diffAddedLineNumberBg = "none";
      diffRemovedLineNumberBg = "none";
      markdownText = "base05";
      markdownHeading = "base0D";
      markdownLink = "base0D";
      markdownLinkText = "base0C";
      markdownCode = "base0B";
      markdownBlockQuote = "base03";
      markdownEmph = "base09";
      markdownStrong = "base0A";
      markdownHorizontalRule = "base03";
      markdownListItem = "base0D";
      markdownListEnumeration = "base0C";
      markdownImage = "base0E";
      markdownImageText = "base0C";
      markdownCodeBlock = "base05";
      syntaxComment = "base03";
      syntaxKeyword = "base0E";
      syntaxFunction = "base0D";
      syntaxVariable = "base07";
      syntaxString = "base0B";
      syntaxNumber = "base09";
      syntaxType = "base0A";
      syntaxOperator = "base0E";
      syntaxPunctuation = "base05";
    };
  };
  opencodeThemeFile = pkgs.writeText "dashvim.json" opencodeTheme;

  opencodeTuiConfig = builtins.toJSON {
    "$schema" = "https://opencode.ai/tui.json";
    theme = config'.opencode.theme;
  };
  opencodeTuiConfigFile = pkgs.writeText "tui.json" opencodeTuiConfig;

  # Merge opencode config
  opencodeBaseConfig = {
    "$schema" = "https://opencode.ai/config.json";
    permission = "allow";
    compaction = {
      auto = true;
      prune = true;
      reserved = 10000;
    };
    autoupdate = true;
    snapshot = true;
  };
  opencodePluginConfig = lib.optionalAttrs (config'.opencode.plugin != []) {
    plugin = config'.opencode.plugin;
  };
  opencodeConfig = opencodeBaseConfig // opencodePluginConfig // config'.opencode.config;
  opencodeConfigFile = pkgs.writeText "opencode.json" (builtins.toJSON opencodeConfig);
in {
  imports = [
    (import ../modules {inherit lib config';})
  ];
  meta.maintainers = with lib.maintainers; [DashieTM];
  options.programs.dashvim = with lib; {
    enable = mkEnableOption "dashvim";

    package = mkOption {
      type = with types; nullOr package;
      default = mkPkg dashvim.neovim;
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
          pkgs.yazi
          pkgs.ripgrep
          pkgs.fd
          pkgs.zoxide
          pkgs.gh
          pkgs.prettierd
        ]
        ++ deps;
      home.file =
        lib.optionalAttrs config'.opencode.enable {
          ".opencode/skills/caveman/SKILL.md".source = ../.opencode/skills/caveman/SKILL.md;
          ".opencode/skills/compact-context/SKILL.md".source = ../.opencode/skills/compact-context/SKILL.md;
          ".config/opencode/themes/dashvim.json".source = opencodeThemeFile;
          ".config/opencode/tui.json".source = opencodeTuiConfigFile;
          "opencode.json".source = opencodeConfigFile;
        };
    }
    // lib.optionalAttrs (options ? environment.systemPackages) {
      environment.systemPackages = lib.optional (config'.package != null) config'.package;
    }
  );
}
