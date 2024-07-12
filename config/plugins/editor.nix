{ pkgs, ... }: {
  plugins = {
    mini = {
      enable = true;
    };
    bufferline = {
      enable = true;
    };
    clipboard-image = {
      clipboardPackage = pkgs.wl-clipboard;
      enable = true;
    };
    refactoring = {
      enable = true;
    };
    nvim-colorizer = {
      enable = true;
    };
    noice = {
      enable = true;
    };
    neo-tree = {
      enable = true;
    };
    coverage = {
      enable = true;
    };
    lualine = {
      enable = true;
    };
    project-nvim = {
      enable = true;
    };
    toggleterm = {
      enable = true;
    };
    surround = {
      enable = true;
    };
    spectre = {
      enable = true;
    };
    treesitter = {
      enable = true;
    };
    diffview = {
      enable = true;
    };
    edgy = {
      enable = true;
    };
    dressing = {
      enable = true;
    };
    glow = {
      enable = true;
    };
    instant = {
      enable = true;
    };
    neoscroll = {
      enable = true;
    };
  };

}
