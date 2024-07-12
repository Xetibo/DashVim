{
  lib,
  config',
  mkDashDefault,
  ...
}: {
  vim.dashboard.dashboard-nvim = mkDashDefault {
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
        shortcut = lib.mkIf config'.useDefaultKeybinds [
          {
            icon = " ";
            icon_hl = "DashboardIcon";
            desc = "Find Files";
            desc_hl = "DashboardDesc";
            key = "f";
            key_hl = "DashboardKey";
            keymap = "";
            key_format = "                   %s";
            action = "require('telescope').extensions.file_browser.file_browser({})";
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
            icon = " ";
            icon_hl = "DashboardIcon";
            desc = "Zoxide";
            desc_hl = "DashboardDesc";
            key = "z";
            key_hl = "DashboardKey";
            keymap = "";
            key_format = "                   %s";
            action = "require('telescope').extensions.zoxide.list({})";
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
            action = "require('telescope').extensions.project.project({})";
          }
          {
            icon = "⏻ ";
            icon_hl = "DashboardIcon";
            desc = "Quit";
            desc_hl = "DashboardDesc";
            key = "q";
            key_hl = "DashboardKey";
            keymap = "";
            key_format = "                   %s";
            action = "vim.cmd('qa')";
          }
        ];
        packages = {enable = false;};
        footer = [
          "                                   "
          "https://github.com/Xetibo/DashVim"
        ];
      };
    };
    # TODO config
  };
}
