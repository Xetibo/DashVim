{
  pkgs,
  lib,
  mkDashDefault,
  ...
}: let
  neotestPlugins = with pkgs.vimPlugins; {
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
    "neotest-zig" = mkDashDefault {
      package = neotest-zig;
    };
    "neotest-python" = mkDashDefault {
      package = neotest-python;
    };
    "neotest-java" = mkDashDefault {
      package = neotest-java;
    };
    "neotest-haskell" = mkDashDefault {
      package = neotest-haskell;
    };
    "neotest-bash" = mkDashDefault {
      package = neotest-bash;
    };
    "neotest-dart" = mkDashDefault {
      package = neotest-dart;
    };
  };
  defaultRequireFn = module:
    lib.generators.mkLuaInline
    /*
    lua
    */
    ''
      require('${module}')
    '';
  neotestAdapters = lib.attrsets.mapAttrsToList (name: _: defaultRequireFn name) neotestPlugins;
in {
  vim = {
    extraPlugins =
      neotestPlugins
      // {
        # This is for plugins that can't be configured via the auto route above
      };
    lazy.plugins = with pkgs.vimPlugins; {
      "neotest" = mkDashDefault {
        package = neotest;
        setupModule = "neotest";
        setupOpts = {
          adapters =
            neotestAdapters
            ++ [
              # This is for plugins that can't be configured via the auto route above
            ];
        };
      };
    };
  };
}
