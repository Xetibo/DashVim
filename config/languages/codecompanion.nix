{
  config',
  pkgs,
  mkDashDefault,
  lib,
  ...
}: {
  vim = {
    assistant.copilot.enable = config'.agent.variant == "copilot";
    lazy.plugins = with pkgs.vimPlugins; {
      "codecompanion.nvim" = mkDashDefault {
        package = codecompanion-nvim;
        setupModule = "codecompanion";
        setupOpts =
          {
            display.chat.window.position = "left";
            adapters = {
              acp = {
                opencode =
                  lib.mkLuaInline
                  /*
                  lua
                  */
                  ''
                    function()
                      return require("codecompanion.adapters").extend("opencode", {
                        commands = {
                          -- The default uses the opencode/config.json value
                          default = {
                            "opencode",
                            "acp",
                          },
                          copilot_sonnet_4_5 = {
                            "opencode",
                            "acp",
                            "-m",
                            "github-copilot/claude-sonnet-4.5",
                          },
                        }
                      })
                    end
                  '';
              };
            };
          }
          // config'.agent.config;
      };
    };
  };
}
