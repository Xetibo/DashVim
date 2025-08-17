{pkgs, ...}: {
  vim.telescope = {
    enable = true;
    extensions = [
      {
        name = "fzf";
        packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
        setup = {fzf = {fuzzy = true;};};
      }
      {
        name = "fzy";
        packages = [pkgs.vimPlugins.telescope-fzy-native-nvim];
      }
      {
        name = "zoxide";
        packages = [pkgs.vimPlugins.telescope-zoxide];
      }
      {
        name = "projects";
        packages = [pkgs.vimPlugins.telescope-project-nvim];
      }
      {
        name = "ui-select";
        packages = [pkgs.vimPlugins.telescope-ui-select-nvim];
      }
      {
        name = "undo";
        packages = [pkgs.vimPlugins.telescope-undo-nvim];
      }
      {
        name = "media-files";
        packages = [pkgs.vimPlugins.telescope-media-files-nvim];
      }
      {
        name = "file_browser";
        packages = [pkgs.vimPlugins.telescope-file-browser-nvim];
      }
    ];
    setupOpts = {
      borders = true;
      borderchars = {
        prompt = ["─" "│" "─" "│" "╭" "╮" "╯" "╰"];
        preview = ["─" "│" "─" "│" "╭" "╮" "╯" "╰"];
        results = ["─" "│" "─" "│" "╭" "╮" "╯" "╰"];
      };
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
}
