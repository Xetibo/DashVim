{
  description = "A nixvim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:NixOs/nixpkgs/nixos-25.05";
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
          stable = import inputs.stable {
            inherit system;
            config = {
              allowBroken = true;
            };
          };
          deps = import ./lib/dependencies.nix {inherit pkgs stable;};
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
                lspServers = {};
              };
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
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowBroken = true;
              };
            };
            inherit stable;
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
            default = package.neovim;
            minimal = custom.neovim;
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
}
