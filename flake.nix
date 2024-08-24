{
  description = "A nixvim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
    base16.url = "github:SenchoPens/base16.nix";
  };

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, system, ... }@orig:
        let package = (import ./lib { inherit system inputs pkgs; });
        in {
          checks = { default = package.test_dashvim; };

          packages = { default = package.build_dashvim; };
        };

      flake = toplevel@{ ... }: rec {
        nixosModules = {
          home-manager = homeManagerModules.default;
          dashvim = import ./hm inputs.self;
        };
        homeManagerModules = rec {
          dashvim = import ./hm inputs.self;
          default = dashvim;
        };
      };
    };
}
