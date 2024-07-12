{
  pkgs,
  lib,
  mkDashDefault,
  ...
}: {
  vim = {
    extraPlugins = with pkgs.vimPlugins; {
      "neotest-rust" = mkDashDefault {
        package = neotest-rust;
      };
      "neotest-vitest" = mkDashDefault {
        package = neotest-vitest;
      };
      "neotest-jest" = mkDashDefault {
        package = neotest-jest;
      };
      "neotest-dotnet" = mkDashDefault {
        package = neotest-dotnet;
      };
      "neotest-go" = mkDashDefault {
        package = neotest-go;
      };
    };
    lazy.plugins = with pkgs.vimPlugins; {
      # TODO add more
      "neotest" = mkDashDefault {
        package = neotest;
        setupModule = "neotest";
        setupOpts = {
          adapters = [
            # TODO just no
            (lib.generators.mkLuaInline
              /*
              lua
              */
              ''
                require('neotest-rust')
              '')
            (lib.generators.mkLuaInline
              /*
              lua
              */
              ''
                require('neotest-vitest')
              '')
            (lib.generators.mkLuaInline
              /*
              lua
              */
              ''
                require('neotest-jest')
              '')
            (lib.generators.mkLuaInline
              /*
              lua
              */
              ''
                require('neotest-dotnet')
              '')
            (lib.generators.mkLuaInline
              /*
              lua
              */
              ''
                require('neotest-go')
              '')
          ];
        };
      };
    };
  };
}
