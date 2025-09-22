{
  pkgs,
  stable,
  ...
}: let
  easyDotnet = pkgs.buildDotnetGlobalTool {
    pname = "EasyDotnet";
    version = "1.0.28";
    nugetSha256 = "sha256-pVtueIzBjthNm3tmxl1ld/yxdCW0Swj5r/pOVoj6tuc=";
    executables = ["dotnet-easydotnet"];
  };
in
  with pkgs; [
    easyDotnet
    lldb
    netcoredbg
    vscode-js-debug
    yazi
    ripgrep
    fd
    zoxide
    gh
  ]
