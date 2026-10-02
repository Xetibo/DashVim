# Home Manager standalone agent integration
# Seeds ~/.config/agents/agentic.md once (copy-if-missing, user-editable
# afterwards) and points standalone Codex at it (symlink-if-missing).
# Nix never overwrites either destination; only the seed content is generated.
{
  lib,
  pkgs,
}: let
  standalone = import ../lib/standalone-agent.nix {inherit pkgs lib;};
in {
  inherit (standalone) baseFile sharedInstructionPath;

  # Activation script installed by hm/default.nix under home.activation.
  activationScript = ''
    set -eu
    seed="${standalone.baseFile}"
    dest="$HOME/.config/agents/agentic.md"
    if [ ! -e "$dest" ]; then
      mkdir -p "$(dirname "$dest")"
      cp "$seed" "$dest"
      chmod u+rw "$dest"
      echo "dashvim: seeded $dest from Nix base (future edits are yours)"
    fi
    codexDest="$HOME/.codex/AGENTS.md"
    if [ ! -e "$codexDest" ] && [ ! -L "$codexDest" ]; then
      mkdir -p "$(dirname "$codexDest")"
      ln -s "$dest" "$codexDest"
      echo "dashvim: linked $codexDest -> $dest"
    fi
  '';
}
