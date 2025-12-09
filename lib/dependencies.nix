{pkgs, ...}: let
  easyDotnet = pkgs.buildDotnetGlobalTool {
    pname = "EasyDotnet";
    version = "2.2.28";
    nugetSha256 = "sha256-udPf2Ws6B2YflySz+hd+vFrIgUVwsXPt2PxZQMovKxI=";
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
    roslyn-ls
    git
    direnv
    nerd-fonts.jetbrains-mono
    kitty
    fish
  ]
