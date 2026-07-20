{
  pkgs,
  inputs,
  system,
  enableOpencode ? true,
  enableAgent ? false,
  ...
}: let
  easyDotnet = pkgs.buildDotnetGlobalTool {
    pname = "EasyDotnet";
    version = "2.2.28";
    nugetSha256 = "sha256-udPf2Ws6B2YflySz+hd+vFrIgUVwsXPt2PxZQMovKxI=";
    executables = ["dotnet-easydotnet"];
  };
  firefoxDebugAdapter = pkgs.callPackage ./firefox-debug-adapter.nix {};
in
  with pkgs;
    [
      easyDotnet
      lldb
      netcoredbg
      vscode-js-debug
      firefoxDebugAdapter
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
      neovide
      inputs.sqlit.packages.${system}.sqlit
      prettierd
    ]
    ++ pkgs.lib.optional enableOpencode pkgs.opencode
    ++ pkgs.lib.optional enableOpencode pkgs.opencode-desktop
    ++ pkgs.lib.optional enableAgent pkgs.github-copilot-cli
