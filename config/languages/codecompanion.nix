{config', ...}: {
  vim.assistant = {
    copilot.enable = config'.agent.variant == "copilot";
    codecompanion-nvim = {
      enable = true;
      setupOpts =
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
  };
}
