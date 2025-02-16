{
  config' ? {},
  inputs,
  pkgs,
  dashLib,
  ...
}:
inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  extraSpecialArgs = {inherit config';};
  modules = [
    {_module.args = inputs // {inherit pkgs dashLib;};}
    ../config
  ];
}
