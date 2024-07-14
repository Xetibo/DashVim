{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins;[
    yazi-nvim
    telescope-zoxide
    telescope-project-nvim
  ];
  plugins.dressing = {
    enable = true;
  };
  plugins.telescope = {
    enable = true;
    extensions = {
      file-browser.enable = true;
      fzf-native.enable = true;
      fzy-native.enable = true;
      ui-select.enable = true;
      media-files.enable = true;
      undo.enable = true;
    };
    enabledExtensions = [
      # "project"
      "zoxide"
    ];
  };
}
