{ lib, writeShellScriptBin, nodejs, vscode-extensions }:

let
  extension = vscode-extensions.firefox-devtools.vscode-firefox-debug;
  adapterPath = "${extension}/share/vscode/extensions/firefox-devtools.vscode-firefox-debug/dist/adapter.bundle.js";
in
writeShellScriptBin "firefox-debug-adapter" ''
  exec "${lib.getExe nodejs}" "${adapterPath}" "$@"
''
