{
  lib,
  config',
  mkDashDefault,
  ...
}: {
  vim.filetree.neo-tree = {
    enable = true;
    setupOpts = {
      enable_cursor_hijack = mkDashDefault true;
      popupBorderStyle = mkDashDefault "rounded";
      useDefaultMappings = mkDashDefault false;
      filesystem = {
        hijack_netrw_behavior = mkDashDefault "open_current";
        follow_current_file = {
          enabled = mkDashDefault true;
          leave_dirs_open = mkDashDefault true;
        };
        filteredItems = {
          hideDotfiles = mkDashDefault false;
          hideGitignored = mkDashDefault false;
        };
        groupEmptyDirs = mkDashDefault true;
        bindToCwd = mkDashDefault false;
      };
      window = {
        position = mkDashDefault "right";
        mappings = lib.mkIf config'.useDefaultKeybinds {
          "<2-LeftMouse>" = mkDashDefault "open";
          "<cr>" = mkDashDefault "open";
          "<esc>" = mkDashDefault "revert_preview";
          P = {
            command = mkDashDefault "toggle_preview";
            config = {use_float = mkDashDefault true;};
          };
          l = mkDashDefault "none";
          S = mkDashDefault "open_split";
          s = mkDashDefault "open_vsplit";
          t = mkDashDefault "open_tabnew";
          w = mkDashDefault "open_with_window_picker";
          C = mkDashDefault "close_node";
          z = mkDashDefault "close_all_nodes";
          R = mkDashDefault "refresh";
          a = {
            command = mkDashDefault "add";
            config = {
              show_path = mkDashDefault "none";
            };
          };
          A = mkDashDefault "add_directory";
          d = mkDashDefault "delete";
          r = mkDashDefault "rename";
          y = mkDashDefault "copy_to_clipboard";
          x = mkDashDefault "cut_to_clipboard";
          p = mkDashDefault "paste_from_clipboard";
          c = mkDashDefault "copy";
          m = mkDashDefault "move";
          e = mkDashDefault "toggle_auto_expand_width";
          q = mkDashDefault "close_window";
          "?" = mkDashDefault "show_help";
          "<" = mkDashDefault "prev_source";
          ">" = mkDashDefault "next_source";
        };
      };
    };
  };
}
