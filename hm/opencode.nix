# Home Manager opencode integration
# Generates theme, tui config, opencode.json, and deploys skills
{
  lib,
  pkgs,
  config',
  inputs,
}: let
  base16Lib = pkgs.callPackage inputs.base16.lib {};

  opencodeFiles = import ../lib/opencode-config.nix {
    inherit pkgs lib base16Lib;
    colorscheme = config'.colorscheme;
    accentColor = config'.accentColor;
    opencodeThemeName = config'.opencode.theme;
    opencodeExtraConfig = config'.opencode.config;
    opencodePlugins = config'.opencode.plugin;
    skillsPath = ../.opencode/skills;
    instructionPaths = [
      "~/.opencode/skills/caveman/SKILL.md"
      "~/.opencode/skills/compact-context/SKILL.md"
    ];
  };
in {
  homeFiles = {
    ".opencode/skills/caveman/SKILL.md".source = ../.opencode/skills/caveman/SKILL.md;
    ".opencode/skills/compact-context/SKILL.md".source = ../.opencode/skills/compact-context/SKILL.md;
    ".opencode/commands/compact.md".source = ../.opencode/commands/compact.md;
    ".opencode/commands/caveman.md".source = ../.opencode/commands/caveman.md;
    ".config/opencode/themes/dashvim.json".source = opencodeFiles.themeFile;
    ".config/opencode/tui.json".source = opencodeFiles.tuiConfigFile;
    ".config/opencode/opencode.json".source = opencodeFiles.configFile;
  };
}
