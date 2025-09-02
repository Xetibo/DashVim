{
  pkgs,
  stable,
  ...
}:
with pkgs; [
  lldb
  netcoredbg
  stable.roslyn-ls
  vscode-js-debug
  yazi
  ripgrep
  fd
  zoxide
  gh
]
