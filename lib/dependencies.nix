{
  pkgs,
  stable,
  ...
}:
with pkgs; [
  netcoredbg
  stable.roslyn-ls
  vscode-js-debug
  yazi
  ripgrep
  fd
  zoxide
  gh
]
