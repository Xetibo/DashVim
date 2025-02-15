{
  config' ? {},
  system,
  inputs,
  pkgs,
  ...
}: let
  nixvimLib = inputs.nixvim.lib.${system};
  nixvim' = inputs.nixvim.legacyPackages.${system};
  nixvimModule = {
    inherit pkgs;
    module = import ../config;
    extraSpecialArgs = {
      inherit inputs config';
    };
  };
in {
  build_dashvim = nixvim'.makeNixvimWithModule nixvimModule;
  test_dashvim = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
}
