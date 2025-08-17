{
  config' ? {},
  inputs,
  pkgs,
  dashLib,
  ...
}:
inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  extraSpecialArgs = {inherit config' dashLib;};
  modules = [
    {_module.args = inputs // {inherit pkgs dashLib;};}
    ../config
  ];
}
