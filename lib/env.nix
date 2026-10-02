{
  pkgs,
  neovim,
  system,
  inputs,
  wrapOpencode ? true,
  enableAgent ? false,
}: let
  deps = import ./dependencies.nix {
    inherit pkgs system inputs enableAgent;
    enableOpencode = !wrapOpencode;
  };
  base16Lib = pkgs.callPackage inputs.base16.lib {};

  skillsPath = ../.opencode/skills;

  standalone = import ./standalone-agent.nix {
    inherit pkgs;
    lib = pkgs.lib;
  };

  opencodeFiles = import ./opencode-config.nix {
    inherit pkgs base16Lib skillsPath;
    lib = pkgs.lib;
    # Standalone opencode reads the shared seed file (same as HM).
    instructionPaths = [
      standalone.sharedInstructionPath
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
        --run 'mkdir -p ''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/themes && cp -f ${opencodeFiles.globalConfigDir}/themes/dashvim.json ''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/themes/dashvim.json 2>/dev/null || true' \
        --run 'dest="$HOME/.config/agents/agentic.md"; if [ ! -e "$dest" ]; then mkdir -p "$(dirname "$dest")" && cp ${standalone.baseFile} "$dest" && chmod u+rw "$dest" 2>/dev/null || true; fi'
    '';
  };

  opencodePkgs = pkgs.lib.optional wrapOpencode wrappedOpencode;
in
  pkgs.buildEnv {
    name = "nvim";
    paths = [neovim] ++ opencodePkgs ++ deps;
  }
