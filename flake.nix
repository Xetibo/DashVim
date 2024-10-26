{
  description = "A nixvim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
    base16.url = "github:SenchoPens/base16.nix";
    blink.url = "github:Saghen/blink.cmp";
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      peng@{ ... }:
      {
        imports = [
          ./modules
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
          "aarch64-apple-darwin"
        ];

        perSystem =
          {
            pkgs,
            system,
            lib,
            ...
          }:
          let
            customConfig = peng.config.programs.dashvim // {
              lsp = {
                useDefaultSpecialLspServers = false;
                lspServers = { };
              };
            };
            package = (
              import ./lib {
                inherit system inputs pkgs;
                config' = peng.config.programs.dashvim;
              }
            );
            custom = (
              import ./lib {
                inherit system inputs pkgs;
                config' = customConfig;
              }
            );
          in
          {
            checks = {
              default = package.test_dashvim;
            };
            packages = {
              default = package.build_dashvim;
              minimal = custom.build_dashvim;
              docs = import ./docs {
                inherit inputs pkgs lib;
              };
            };
          };

        flake =
          { ... }:
          rec {
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
