{
  config',
  pkgs,
  lib,
  mkDashDefault,
  ...
}: let
  toolchain = import ../../lib/toolchain.nix {inherit lib pkgs;};
  # Probe shapes mirror the nixpkgs ngserver wrapper:
  #   --tsProbeLocations entries point at the typescript package dir
  #   (holds lib/tsserverlibrary.js);
  #   --ngProbeLocations entries point at a node_modules dir (holds @angular/).
  nixTsProbe = "${pkgs.typescript_5}/lib/node_modules/typescript";
  nixNgProbe = "${pkgs.angular-language-server}/lib/node_modules";
  ngserverCommand =
    if config'.toolchain.preferProjectTools or false
    then toolchain.bin "ngserver"
    else "${pkgs.angular-language-server}/bin/ngserver";
in {
  vim = {
    lsp.servers.angular = {
      enable = mkDashDefault true;
      filetypes = mkDashDefault ["html" "htmlangular" "typescript" "typescriptreact"];
      root_markers = mkDashDefault ["angular.json" "nx.json"];
      cmd = lib.mkOverride 80 (lib.generators.mkLuaInline (builtins.readFile ./angular/cmd.lua));
    };
    luaConfigRC.dashvim-angular =
      # Prelude: only the nix store paths need interpolation; everything else
      # lives in angular/setup.lua for real syntax highlighting and lua_ls.
      ''
        _G.DashVimAngular = {
          root_markers = { "angular.json", "nx.json" },
          nix = {
            ts_probe = "${nixTsProbe}",
            ng_probe = "${nixNgProbe}",
            ngserver = "${ngserverCommand}",
          },
        }
      ''
      + builtins.readFile ./angular/setup.lua;
  };
}
