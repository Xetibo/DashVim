{config', ...}: {
  vim = {
    options = {
      shell = "fish";
    };

    enableLuaLoader = true;

    binds.whichKey = {
      enable = true;
      # TODO config
    };

    dashboard.dashboard-nvim = {
      enable = true;
      setupOpts = {
        theme = "hyper";
        disable_move = true;
        hide = [
          "lualine"
          "tabline"
          "winbar"
        ];
        config = {
          header = config'.dashboardAscii;
          shortcut = [
            {
              icon = " ";
              icon_hl = "DashboardIcon";
              desc = "Find Files";
              desc_hl = "DashboardDesc";
              key = "f";
              key_hl = "DashboardKey";
              keymap = "";
              key_format = "                   %s";
              action = "TODO -> fzf";
            }
            {
              icon = " ";
              icon_hl = "DashboardIcon";
              desc = "Yazi";
              desc_hl = "DashboardDesc";
              key = "y";
              key_hl = "DashboardKey";
              keymap = "";
              key_format = "                   %s";
              action = "require('yazi').yazi()";
            }
            {
              icon = "󰺄 ";
              icon_hl = "DashboardIcon";
              desc = "Projects";
              desc_hl = "DashboardDesc";
              key = "p";
              key_hl = "DashboardKey";
              keymap = "";
              key_format = "                   %s";
              action = "TODO -> fzf";
            }
            {
              icon = "⏻ ";
              icon_hl = "DashboardIcon";
              desc = "Quit";
              desc_hl = "DashboardDesc";
              key = "y";
              key_hl = "DashboardKey";
              keymap = "";
              key_format = "                   %s";
              action = "im.cmd('qa')";
            }
          ];
          packages = {enable = false;};
          footer = [
            "                                   "
            "https://github.com/DashieTM/DashVim"
          ];
        };
      };
      # TODO config
    };

    git = {
      gitsigns = {
        enable = true;
      };
      git-conflict = {
        enable = true;
      };
      # TODO neogit
    };

    ui.noice = {
      enable = true;
    };

    visuals.rainbow-delimiters.enable = true;
    extraLuaFiles = [
      ./lua/yankAndPaste.lua
    ];
  };
}
