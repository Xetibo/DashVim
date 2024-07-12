{
  plugins.neo-tree = {
    enable = true;
    popupBorderStyle = "rounded";
    useDefaultMappings = false;
    filesystem = {
      hijackNetrwBehavior = "open_current";
      filteredItems = {
        hideDotfiles = false;
        hideGitignored = false;
      };
      groupEmptyDirs = true;
      bindToCwd = false;
    };
    window = {
      position = "right";
      mappings = {
        "<space>" = {
          command = "toggle_node";
          # disable `nowait` if you have existing combos starting with this char that you want to use
          nowait = false;
        };
        "<2-LeftMouse>" = "open";
        "<cr>" = "open";
        "<esc>" = "revert_preview";
        P = {
          command = "toggle_preview";
          config = {use_float = true;};
        };
        S = "open_split";
        s = "open_vsplit";
        t = "open_tabnew";
        w = "open_with_window_picker";
        C = "close_node";
        z = "close_all_nodes";
        R = "refresh";
        a = {
          command = "add";
          # some commands may take optional config options, see `:h neo-tree-mappings` for details
          config = {
            show_path = "none"; # "none", "relative", "absolute"
          };
        };
        A = "add_directory"; # also accepts the config.show_path and config.insert_as options.
        d = "delete";
        r = "rename";
        y = "copy_to_clipboard";
        x = "cut_to_clipboard";
        p = "paste_from_clipboard";
        c = "copy"; # takes text input for destination, also accepts the config.show_path and config.insert_as options
        m = "move"; # takes text input for destination, also accepts the config.show_path and config.insert_as options
        e = "toggle_auto_expand_width";
        q = "close_window";
        "?" = "show_help";
        "<" = "prev_source";
        ">" = "next_source";
      };
    };
  };
}
