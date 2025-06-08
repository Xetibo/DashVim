{
  pkgs,
  lib,
  config',
  ...
}:
lib.mkIf config'.agent.enable {
  extraPlugins = with pkgs.vimPlugins; [
    codecompanion-nvim
  ];
  extraConfigLua = ''
    require("codecompanion").setup({
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend(${config'.agent.variant}, {
            env = {
              api_key = "${
      if (config'.agent.key != null)
      then config'.agent.key
      else ""
    }",
            },
          })
        end,
      },
    })
  '';
}
