{
  description = "A nixvim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
    flake-parts.url = "github:hercules-ci/flake-parts";
    base16.url = "github:SenchoPens/base16.nix";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} (
      orig @ {lib, ...}: let
        config' = {
          lsp.special.useAngular = true;
        };
        dashLib = import ./lib/lsp.nix {inherit lib;};
      in {
        imports = [
          (import ./modules {inherit lib config' dashLib;})
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
          customConfig =
            lib.attrsets.overrideExisting
            orig.config.programs.dashvim
            {
              agent.enable = true;
              agent.variant = "copilot";
              agent.key = "";
              agent.config = {};
              lsp = {
                useDefaultSpecialLspServers = true;
                lspServers = {};
              };
            };
          package = (
            import ./lib {
              inherit system inputs pkgs dashLib;
              config' = orig.config.programs.dashvim;
            }
          );
          custom = (
            import ./lib {
              inherit system inputs pkgs dashLib;
              config' = customConfig;
            }
          );
        in {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system dashLib;
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
          packages = {
            dependencies = deps;
            dashLib = dashLib;
            default = package.neovim;
            minimal = custom.neovim;
            docs = import ./docs {
              inherit inputs pkgs lib dashLib;
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
