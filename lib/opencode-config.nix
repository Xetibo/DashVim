# Shared opencode configuration generation
# Used by both Home Manager module and flake (nix run)
{
  pkgs,
  lib,
  base16Lib,
  colorscheme ? null,
  accentColor ? null,
  opencodeThemeName ? "dashvim",
  opencodeExtraConfig ? {},
  opencodePlugins ? [],
  skillsPath,
  # Paths to skill instruction files as they will appear in opencode.json
  # For HM: ~/.opencode/skills/..., for nix run: nix store paths
  instructionPaths ? [],
}: let
  # --- Base16 theme generation ---
  parsedBase =
    if colorscheme == null
    then {
      # catppuccin default (matches modules/default.nix)
      base00 = "1e1e2e";
      base01 = "181825";
      base02 = "313244";
      base03 = "45475a";
      base04 = "585b70";
      base05 = "cdd6f4";
      base06 = "f5e0dc";
      base07 = "b4befe";
      base08 = "f38ba8";
      base09 = "fab387";
      base0A = "f9e2af";
      base0B = "a6e3a1";
      base0C = "94e2d5";
      base0D = "89b4fa";
      base0E = "cba6f7";
      base0F = "f2cdcd";
    }
    else if builtins.isAttrs colorscheme
    then colorscheme
    else "${pkgs.base16-schemes}/share/themes/${colorscheme}.yaml";

  resolvedAccent =
    if accentColor != null
    then accentColor
    else if builtins.isAttrs parsedBase
    then parsedBase.base0D
    else null;

  parsed =
    if resolvedAccent != null
    then
      (
        if builtins.isAttrs parsedBase
        then parsedBase // {base0D = resolvedAccent;}
        else parsedBase
      )
    else parsedBase;
  scheme = base16Lib.mkSchemeAttrs parsed;

  # --- Theme file ---
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

  # --- TUI config ---
  opencodeTuiConfig = builtins.toJSON {
    "$schema" = "https://opencode.ai/tui.json";
    theme = opencodeThemeName;
  };

  # --- Main opencode.json config ---
  opencodeBaseConfig =
    {
      "$schema" = "https://opencode.ai/config.json";
      permission = "allow";
      compaction = {
        auto = true;
        prune = true;
        reserved = 10000;
      };
      autoupdate = true;
      snapshot = true;
    }
    // lib.optionalAttrs (instructionPaths != []) {
      instructions = instructionPaths;
    };
  opencodePluginConfig = lib.optionalAttrs (opencodePlugins != []) {
    plugin = opencodePlugins;
  };
  opencodeConfig = opencodeBaseConfig // opencodePluginConfig // opencodeExtraConfig;

  # --- Derivation outputs ---
  themeFile = pkgs.writeText "dashvim.json" opencodeTheme;
  tuiConfigFile = pkgs.writeText "tui.json" opencodeTuiConfig;
  configFile = pkgs.writeText "opencode.json" (builtins.toJSON opencodeConfig);

  # --- Config directory for OPENCODE_CONFIG_DIR ---
  # Bundles skills and commands so opencode can discover them
  commandsPath = ../. + "/.opencode/commands";
  configDir = pkgs.runCommand "opencode-config-dir" {} ''
    mkdir -p $out/skills/caveman
    mkdir -p $out/skills/compact-context
    mkdir -p $out/commands
    cp ${skillsPath}/caveman/SKILL.md $out/skills/caveman/SKILL.md
    cp ${skillsPath}/compact-context/SKILL.md $out/skills/compact-context/SKILL.md
    cp ${commandsPath}/compact.md $out/commands/compact.md
    cp ${commandsPath}/caveman.md $out/commands/caveman.md
  '';

  # --- Global config directory (~/.config/opencode equivalent) ---
  globalConfigDir = pkgs.runCommand "opencode-global-config" {} ''
    mkdir -p $out/themes
    cp ${themeFile} $out/themes/dashvim.json
    cp ${tuiConfigFile} $out/tui.json
    cp ${configFile} $out/opencode.json
  '';
in {
  inherit
    themeFile
    tuiConfigFile
    configFile
    configDir
    globalConfigDir
    opencodeTheme
    opencodeTuiConfig
    opencodeConfig
    ;
}
