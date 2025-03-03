{
  config' ? {},
  system,
  inputs,
  pkgs,
  dashLib,
  ...
}: let
  nixvimLib = inputs.nixvim.lib.${system};
  nixvim' = inputs.nixvim.legacyPackages.${system};
  nixvimModule = {
    inherit pkgs;
    module = import ../config;
    extraSpecialArgs = {
      inherit inputs system config' dashLib;
    };
  };
in {
  build_dashvim = nixvim'.makeNixvimWithModule nixvimModule;
  test_dashvim = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
}
