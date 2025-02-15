{...}: {
  vim = {
    enableLuaLoader = true;

    binds.whichKey = {
      enable = true;
      # TODO config
    };

    dashboard.dashboard-nvim = {
      enable = true;
      # TODO config
    };

    git = {
      gitsigns = {
        enable = true;
      };

      # TODO neogit
    };

    visuals.rainbow-delimiters.enable = true;
    additionalRuntimePaths = [
      ./lua
    ];
  };
}
