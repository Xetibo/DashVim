{
  pkgs,
  mkDashDefault,
  ...
}: let
  treesitter-patterns = pkgs.tree-sitter.buildGrammar {
    language = "lua_patterns";
    version = "0.0.1";
    src = pkgs.fetchFromGitHub {
      owner = "OXY2DEV";
      repo = "tree-sitter-lua_patterns";
      rev = "30540892ddbb97b09837db78a97556ce563c90a9";
      hash = "sha256-5665/Phv5csnOkQlxUiqvqaVGA3ngIOY6dechqh49Cs=";
    };
    meta.homepage = "https://github.com/OXY2DEV/tree-sitter-lua_patterns";
  };
in {
  vim = {
    treesitter.grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      treesitter-patterns
      angular
      typescript
      javascript
      html
      css
      fsharp
      c_sharp
      rust
      cpp
      c
      json
      toml
      yaml
    ];
    ui.colorizer.enable = mkDashDefault true;
    lazy.plugins = with pkgs.vimPlugins; {
      "instant.nvim" = mkDashDefault {
        package = instant-nvim;
      };
      "live-share.nvim" = mkDashDefault {
        package = live-share-nvim;
        setupModule = "live-share";
        setupOpts = {
          port_internal = 8765;
          max_attempts = 40;
          service = "serveo.net";
        };
      };
      "patterns.nvim" = mkDashDefault {
        package = patterns-nvim;
        setupModule = "patterns";
      };
      "multicursor.nvim" = mkDashDefault {
        package = multicursor-nvim;
        setupModule = "multicursor-nvim";
      };
      "grug-far.nvim" = mkDashDefault {
        package = grug-far-nvim;
        setupModule = "grug-far";
      };
    };
  };
}
