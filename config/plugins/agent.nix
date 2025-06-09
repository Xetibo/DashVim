{
  pkgs,
  lib,
  config',
  ...
}:
lib.mkIf config'.agent.enable {
  extraPlugins = with pkgs.vimPlugins; [
    codecompanion-nvim
    copilot-lua
  ];
  extraConfigLua =
    if (config'.agent.variant == "copilot")
    then
      /*
      lua
      */
      ''require("copilot").setup()''
    else '''';
  plugins.codecompanion = {
    enable = true;
    settings =
      {
        strategies = {
          agent = {
            adapter = config'.agent.variant;
          };
          chat = {
            adapter = config'.agent.variant;
          };
          inline = {
            adapter = config'.agent.variant;
          };
        };
      }
      // config'.agent.config;
  };
}
