{
  description = "A nixvim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:NixOs/nixpkgs/nixos-25.05";
    nvf.url = "github:notashelf/nvf";
    flake-parts.url = "github:hercules-ci/flake-parts";
    base16.url = "github:SenchoPens/base16.nix";
    statix.url = "github:oppiliappan/statix";
    sqlit.url = "github:Maxteabag/sqlit";
    nvim-mcp = {
      url = "github:linw1995/nvim-mcp/986be68135a05ebdb727e73e609ffda0bbbbfdf6";
      flake = false;
    };
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} (
      orig @ {lib, ...}: let
        config' = {
          lsp.special.useAngular = true;
          agent = {
            enable = true;
          };
        };
      in {
        imports = [
          (import ./modules {inherit lib config';})
        ];
        programs.dashvim.agent.enable = true;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
          "aarch64-apple-darwin"
        ];

        perSystem = {
          system,
          lib,
          ...
        }: let
          stable = import inputs.stable {
            inherit system;
            config = {
              allowBroken = true;
              # Ok look, I get it, these neovim plugins have *no* license, but common.
              allowUnfree = true;
            };
            overlays = [
              (_: _: {
                statix = inputs.statix.packages.${system}.default;
              })
            ];
          };
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowBroken = true;
              # Ok look, I get it, these neovim plugins have *no* license, but common.
              allowUnfree = true;
            };
            overlays = [
              (_: _: {
                statix = inputs.statix.packages.${system}.default;
              })
            ];
          };
          customConfig =
            lib.attrsets.overrideExisting
            orig.config.programs.dashvim
            {
              agent = {
                enable = true;
                variant = "copilot";
                key = "";
                config = {};
                ninetyNine = orig.config.programs.dashvim.agent.ninetyNine;
              };
              lsp = {
                useDefaultSpecialLspServers = true;
                tailwind = orig.config.programs.dashvim.lsp.tailwind;
                special = orig.config.programs.dashvim.lsp.special;
                lspServers = {
                  nix = {
                    enable = true;
                    lsp.enable = true;
                  };
                };
                additionalConfig = {};
              };
            };
          deps = import ./lib/dependencies.nix {
            inherit pkgs stable system inputs;
          };
          package = import ./lib {
            inherit system inputs pkgs lib stable;
            config' = orig.config.programs.dashvim;
          };
          custom = import ./lib {
            inherit system inputs pkgs lib stable;
            config' = customConfig;
          };
        in {
          _module.args = {
            inherit stable pkgs;
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs;
              [
                nuget
                lua
                python3
              ]
              ++ deps;
          };
          packages = let
            enableAgent = orig.config.programs.dashvim.agent.enable or false;
            mkPkgBase = enableAgent: neovim:
              import ./lib/env.nix {
                inherit pkgs neovim system inputs enableAgent;
              };
            mkPkg = enableAgent:
              import ./lib/mkPkg.nix {
                inherit pkgs;
                mkPkgBase = mkPkgBase enableAgent;
              };
          in {
            dependencies = deps;
            lint = inputs.statix.packages.${system}.default;
            format = pkgs.alejandra;
            default = (mkPkg enableAgent) package.neovim;
            minimal = (mkPkg customConfig.agent.enable) custom.neovim;
            docs = import ./docs {
              inherit inputs pkgs lib stable;
            };
          };
        };

        flake = _: rec {
          nixosModules = {
            home-manager = homeManagerModules.default;
            dashvim = import ./hm inputs;
          };
          homeManagerModules = rec {
            dashvim = import ./hm inputs;
            default = dashvim;
          };
        };
      }
    );

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
