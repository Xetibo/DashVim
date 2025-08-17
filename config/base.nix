{config', ...}: {
  vim = {
    clipboard = {
      enable = true;
      providers.wl-copy.enable = true;
      registers = "unnamedplus";
    };
        
    lineNumberMode = "number";

    globals = {
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
    };

    options = {
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

    enableLuaLoader = true;

    binds.whichKey = {
      enable = true;
    };

    ui = {
      noice = {
        enable = true;
      };

      borders = {
        enable = true;
        globalStyle = "rounded";
      };
      illuminate.enable = true;
    };
    utility.snacks-nvim = {
      enable = true;
      setupOpts = {
        bigfile.enabled = true;
        input.enabled = true;
        picker.enabled = true;
      };
    };

    visuals.rainbow-delimiters.enable = true;
    extraLuaFiles =
      [
        ./lua/yankAndPaste.lua
      ]
      ++ config'.additionalLuaConfigFiles;
  };
}
