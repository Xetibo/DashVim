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
    tuiPlugins = config'.opencode.tuiPlugin;
    skillsPath = ../.opencode/skills;
    instructionPaths = [
      "~/.opencode/AGENTS.md"
      "~/.opencode/skills/caveman/SKILL.md"
      "~/.opencode/skills/compact-context/SKILL.md"
    ];
  };

in {
  homeFiles = {
    ".opencode/AGENTS.md".source = ../AGENTS.md;
    ".opencode/skills/caveman/SKILL.md".source = ../.opencode/skills/caveman/SKILL.md;
    ".opencode/skills/compact-context/SKILL.md".source = ../.opencode/skills/compact-context/SKILL.md;
    ".opencode/commands/compact.md".source = ../.opencode/commands/compact.md;
    ".opencode/commands/caveman.md".source = ../.opencode/commands/caveman.md;
  };

  xdgConfigFiles = {
    "opencode/themes/dashvim.json".source = lib.mkDefault opencodeFiles.themeFile;
    "opencode/tui.json".source = lib.mkDefault opencodeFiles.tuiConfigFile;
    "opencode/opencode.json".source = lib.mkDefault opencodeFiles.configFile;
    # Deploy both agent configs — runtime switching handled by opencode-nvim plugin
    "opencode/oh-my-openagent-copilot.jsonc".source = ../opencode/oh-my-openagent-copilot.jsonc;
    "opencode/oh-my-openagent-free.jsonc".source = ../opencode/oh-my-openagent-free.jsonc;
  };
}
