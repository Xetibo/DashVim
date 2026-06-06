{
  pkgs,
  neovim,
  system,
  inputs,
  wrapOpencode ? true,
}: let
  deps = import ./dependencies.nix {
    inherit pkgs system inputs;
    enableOpencode = !wrapOpencode;
  };
  base16Lib = pkgs.callPackage inputs.base16.lib {};

  skillsPath = ../.opencode/skills;

  opencodeFiles = import ./opencode-config.nix {
    inherit pkgs base16Lib skillsPath;
    lib = pkgs.lib;
    instructionPaths = [
      "${../AGENTS.md}"
      "${skillsPath}/caveman/SKILL.md"
      "${skillsPath}/compact-context/SKILL.md"
    ];
  };

  # Wrap opencode binary with config paths
  wrappedOpencode = pkgs.symlinkJoin {
    name = "opencode-wrapped";
    paths = [
      pkgs.opencode
      pkgs.opencode-desktop
    ];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --set OPENCODE_CONFIG "${opencodeFiles.globalConfigDir}/opencode.json" \
        --set OPENCODE_CONFIG_DIR "${opencodeFiles.configDir}" \
        --set OPENCODE_TUI_CONFIG "${opencodeFiles.globalConfigDir}/tui.json" \
        --run 'mkdir -p ''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/themes && cp -n ${opencodeFiles.globalConfigDir}/themes/dashvim.json ''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/themes/dashvim.json 2>/dev/null || true'
    '';
  };

  opencodePkgs = pkgs.lib.optional wrapOpencode wrappedOpencode;
in
  pkgs.buildEnv {
    name = "nvim";
    paths = [neovim] ++ opencodePkgs ++ deps;
  }
