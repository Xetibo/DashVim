{
  pkgs,
  src,
}:
pkgs.rustPlatform.buildRustPackage {
  pname = "nvim-mcp";
  version = "0.7.2";
  inherit src;
  cargoLock.lockFile = src + /Cargo.lock;
  postPatch = ''
    substituteInPlace src/neovim/client.rs \
      --replace-fail '    pub source: String,' '    #[serde(default)]
        pub source: String,'
    substituteInPlace src/neovim/lua/setup_autocmd.lua \
      --replace-fail 'local group =' '${builtins.readFile ./nvim-mcp-notify.lua}
    local group =' \
      --replace-fail 'vim.rpcnotify(0,' 'notify_rpc_clients('
  '';
  env = {
    GIT_COMMIT_SHA = src.rev;
    GIT_DIRTY = "false";
  };
  checkFlags = ["--skip=integration_tests"];
  meta = {
    description = "Neovim buffer and LSP tools over MCP";
    homepage = "https://github.com/linw1995/nvim-mcp";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "nvim-mcp";
  };
}
