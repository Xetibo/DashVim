{
  config',
  pkgs,
  mkDashDefault,
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
            ignore_warnings = true;
            strategies = {
              agent = {
                adapter = config'.agent.variant;
              };
              chat = {
                opts.completion_provider = "blink";
                adapter = config'.agent.variant;
              };
              inline = {
                adapter = config'.agent.variant;
              };
              cmd = {
                adapter = config'.agent.variant;
              };
            };
          }
          // config'.agent.config;
      };
    };
  };
}
