{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
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
    settings = {
      defaults = {
        layout_strategy = "flex";
        layout_config = {
          flex = {
            height = 0.95;
            width = 0.95;
            flip_columns = 300;
            vertical = {
              preview_height = 0.5;
              preview_cutoff = 5;
            };
            horizontal = {
              preview_width = 0.6;
              preview_cutoff = 99;
            };
          };
        };
      };
    };
    enabledExtensions = [
      "zoxide"
    ];
  };
}
