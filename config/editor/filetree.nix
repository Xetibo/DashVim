{
  lib,
  config',
  mkDashDefault,
  ...
}: {
  vim.filetree.neo-tree = mkDashDefault {
    enable = true;
    setupOpts = {
      popupBorderStyle = "rounded";
      useDefaultMappings = false;
      filesystem = {
        hijack_netrw_behavior = "open_current";
        filteredItems = {
          hideDotfiles = false;
          hideGitignored = false;
        };
        groupEmptyDirs = true;
        bindToCwd = false;
      };
      window = {
        position = "right";
        mappings = lib.mkIf config'.useDefaultKeybinds {
          "<2-LeftMouse>" = "open";
          "<cr>" = "open";
          "<esc>" = "revert_preview";
          P = {
            command = "toggle_preview";
            config = {use_float = true;};
          };
          l = "none";
          S = "open_split";
          s = "open_vsplit";
          t = "open_tabnew";
          w = "open_with_window_picker";
          C = "close_node";
          z = "close_all_nodes";
          R = "refresh";
          a = {
            command = "add";
            config = {
              show_path = "none";
            };
          };
          A = "add_directory";
          d = "delete";
          r = "rename";
          y = "copy_to_clipboard";
          x = "cut_to_clipboard";
          p = "paste_from_clipboard";
          c = "copy";
          m = "move";
          e = "toggle_auto_expand_width";
          q = "close_window";
          "?" = "show_help";
          "<" = "prev_source";
          ">" = "next_source";
        };
      };
    };
  };
}
