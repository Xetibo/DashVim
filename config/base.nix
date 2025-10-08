{
  lib,
  config',
  mkDashDefault,
  system,
  ...
}: {
  vim = {
    clipboard = mkDashDefault {
      enable = true;
      providers.wl-copy.enable =
        if (system == "x86_64-linux" || system == "aarch64-linux")
        then true
        else false;

      registers = "unnamedplus";
    };

    lineNumberMode = mkDashDefault "number";

    globals = lib.attrsets.mapAttrs (_: mkDashDefault) {
      fileencoding = "utf-8";
      spelllang = "en_us";
      shell = "fish";
      mapleader = " ";
      autoformat = false;
      gitblame_enabled = false;
      clear_background = true;
      loaded_netrw = true;
      loaded_netrwPlugin = true;
      mkdp_auto_start = true;
      neovide_refresh_rate = 180;
      neovide_refresh_rate_idle = 5;
      neovide_hide_mouse_when_typing = true;
      instant_username = config'.instantUsername;
    };

    options = lib.attrsets.mapAttrs (_: mkDashDefault) {
      swapfile = true;
      wrap = false;
      showmode = true;
      scrolloff = 5;
      scrolljump = 5;
      relativenumber = false;
      guifont = "JetBrainsMono Nerd Font:h14";
      foldenable = false;
      foldmethod = "manual";
      termguicolors = true;
      smartcase = true;
      ignorecase = true;
      number = true;
      shell = "fish";
    };

    enableLuaLoader = mkDashDefault true;

    binds.whichKey = mkDashDefault {
      enable = true;
    };

    ui = {
      noice = mkDashDefault {
        enable = true;
      };

      borders = mkDashDefault {
        enable = true;
        globalStyle = "rounded";
      };
      illuminate.enable = mkDashDefault true;
    };
    utility = {
      direnv.enable = mkDashDefault true;
      snacks-nvim = mkDashDefault {
        enable = true;
        setupOpts = {
          bigfile.enabled = true;
          input.enabled = true;
          picker.enabled = true;
        };
      };
    };

    visuals.rainbow-delimiters.enable = mkDashDefault true;
    extraLuaFiles =
      [
        ./lua/yankAndPaste.lua
        ./lua/dap.lua
      ]
      ++ config'.additionalLuaConfigFiles;
  };
}
