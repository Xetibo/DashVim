{
  config',
  pkgs,
  lib,
  nvim-mcp,
  ...
}: let
  server = import ../../lib/nvim-mcp.nix {
    inherit pkgs;
    src = nvim-mcp;
  };
  plugin = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-mcp";
    version = "0.7.2";
    src = nvim-mcp;
    postInstall = ''
      mkdir -p $out/lua/dashvim
      cp ${./codex-bridge.lua} $out/lua/dashvim/codex-bridge.lua
      cp ${./codex-tools.lua} $out/lua/dashvim/codex-tools.lua
      cat > $out/lua/dashvim/codex-bridge-config.lua <<'EOF'
      return { command = "${lib.getExe server}" }
      EOF
    '';
  };
in
  lib.mkIf config'.agent.enable {
    vim.startPlugins = [plugin];
  }
