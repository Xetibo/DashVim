{
  description = "A nixvim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:NixOs/nixpkgs/nixos-25.05";
    nvf.url = "github:notashelf/nvf";
    flake-parts.url = "github:hercules-ci/flake-parts";
    base16.url = "github:SenchoPens/base16.nix";
    statix.url = "github:oppiliappan/statix";
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
              };
              lsp = {
                useDefaultSpecialLspServers = true;
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
              ]
              ++ deps;
          };
          packages = let
            mkPkgBase = neovim:
              import ./lib/env.nix {
                inherit pkgs neovim system inputs;
              };
            mkPkg = import ./lib/mkPkg.nix {inherit pkgs mkPkgBase;};
          in {
            dependencies = deps;
            lint = inputs.statix.packages.${system}.default;
            format = pkgs.alejandra;
            default = mkPkg package.neovim;
            minimal = mkPkg custom.neovim;
            docs = import ./docs {
              inherit inputs pkgs lib stable;
            };
          };
        };

        flake = _: rec {
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
