# Shared standalone agent instructions (pure agents: Codex CLI, opencode TUI, etc.)
# Builds the seed content for ~/.config/agents/agentic.md from the same
# repo sources opencode deploys: global AGENTS.md + every repo skill
# (currently caveman + compact-context). Editor-hosted Codex (agentic.nvim,
# 99) keeps its own scoped instructions in lib/codex-editor.nix and does
# not read this file.
{
  pkgs,
  lib,
}: let
  skillsDir = ../.opencode/skills;
  skillNames = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir));
  skillFiles = map (name: skillsDir + "/${name}/SKILL.md") skillNames;
  instructionSources = [../AGENTS.md] ++ skillFiles;

  baseText =
    ''
      # Standalone Agent Instructions
      <!--
        Seeded by DashVim (Nix) only when ~/.config/agents/agentic.md is missing.
        Afterwards this file is yours: edit freely, Nix will not overwrite it.
        Pure standalone agents (Codex CLI, opencode TUI, etc.) read this file.
        Editor-hosted Codex (agentic.nvim, 99) uses scoped instructions instead.
      -->

    ''
    + lib.concatMapStrings (src: ''
      <!-- Source: ${src} -->
      ${builtins.readFile src}

    '')
    instructionSources;
  baseFile = pkgs.writeText "agentic-base.md" baseText;
in {
  inherit baseText baseFile skillNames;
  sharedInstructionPath = "~/.config/agents/agentic.md";
}
