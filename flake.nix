{
  description = "A nixvim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
    base16.url = "github:SenchoPens/base16.nix";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} (
      orig @ {lib, ...}: let
        config' = {
          lsp.special.useAngular = true;
        };
      in {
        imports = [
          (import ./modules {inherit lib config';})
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
          "aarch64-apple-darwin"
        ];

        perSystem = {
          pkgs,
          system,
          lib,
          ...
        }: let
          deps = import ./lib/dependencies.nix pkgs;
          dashLib = import ./lib/lsp.nix {inherit lib pkgs;};
          customConfig =
            lib.attrsets.overrideExisting
            orig.config.programs.dashvim
            {
              agent.enable = true;
              agent.variant = "copilot"; # TODO why??
              agent.key = ""; # TODO why??
              agent.config = {}; # TODO why??
              lsp = {
                useDefaultSpecialLspServers = true;
                lspServers = {};
              };
            };
          package = (
            import ./lib {
              inherit system inputs pkgs dashLib deps;
              config' = orig.config.programs.dashvim;
            }
          );
          custom = (
            import ./lib {
              inherit system inputs pkgs dashLib deps;
              config' = customConfig;
            }
          );
        in {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowBroken = true;
            };
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs;
              [
                nuget
              ]
              ++ deps;
          };
          checks = {
            default = package.test_dashvim;
          };
          packages = {
            dependencies = deps;
            default = package.build_dashvim;
            minimal = custom.build_dashvim;
            docs = import ./docs {
              inherit inputs pkgs lib dashLib deps;
            };
          };
        };

        flake = {...}: rec {
          nixosModules = {
            home-manager = homeManagerModules.default;
            dashvim = import ./hm inputs.self;
          };
          homeManagerModules = rec {
            dashvim = import ./hm inputs.self;
            default = dashvim;
          };
        };
      }
    );
}
