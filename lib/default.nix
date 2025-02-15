{
  config' ? {},
  inputs,
  pkgs,
  ...
}:
inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  extraSpecialArgs = {inherit config';};
  modules = [
    {_module.args = inputs // {inherit pkgs;};}
    ../config
  ];
}
