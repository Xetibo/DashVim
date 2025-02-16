{pkgs, ...}: {
  vim.lazy.plugins = with pkgs.vimPlugins; {
    neogit = {
      package = neogit;

      setupModule = "neogit";
      setupOpts = {
        use_default_keymaps = false;
        mappings = {
          commit_editor = {
            "q" = "Close";
            "<c-c><c-c>" = "Submit";
            "<c-c><c-k>" = "Abort";
          };
          commit_editor_I = {
            "<c-c><c-c>" = "Submit";
            "<c-c><c-k>" = "Abort";
          };
          rebase_editor = {
            "p" = "Pick";
            "r" = "Reword";
            "e" = "Edit";
            "s" = "Squash";
            "f" = "Fixup";
            "x" = "Execute";
            "d" = "Drop";
            "b" = "Break";
            "q" = "Close";
            "<cr>" = "OpenCommit";
            "gk" = "MoveUp";
            "gj" = "MoveDown";
            "<c-c><c-c>" = "Submit";
            "<c-c><c-k>" = "Abort";
            "[c" = "OpenOrScrollUp";
            "]c" = "OpenOrScrollDown";
          };
          rebase_editor_I = {
            "<c-c><c-c>" = "Submit";
            "<c-c><c-k>" = "Abort";
          };
          finder = {
            "<cr>" = "Select";
            "<c-c>" = "Close";
            "<esc>" = "Close";
            "<c-n>" = "Next";
            "<c-p>" = "Previous";
            "<down>" = "Next";
            "<up>" = "Previous";
            "<tab>" = "MultiselectToggleNext";
            "<s-tab>" = "MultiselectTogglePrevious";
            "<c-j>" = "NOP";
          };
          popup = {
            "?" = "HelpPopup";
            "A" = "CherryPickPopup";
            "D" = "DiffPopup";
            "M" = "RemotePopup";
            "P" = "PushPopup";
            "X" = "ResetPopup";
            "Z" = "StashPopup";
            "b" = "BranchPopup";
            "B" = "BisectPopup";
            "c" = "CommitPopup";
            "f" = "FetchPopup";
            "l" = "LogPopup";
            "m" = "MergePopup";
            "p" = "PullPopup";
            "r" = "RebasePopup";
            "v" = "RevertPopup";
            "w" = "WorktreePopup";
          };
          status = {
            l = "MoveUp";
            k = "MoveDown";
            "q" = "Close";
            "o" = "OpenTree";
            "I" = "InitRepo";
            "1" = "Depth1";
            "2" = "Depth2";
            "3" = "Depth3";
            "4" = "Depth4";
            "<tab>" = "Toggle";
            "x" = "Discard";
            "s" = "Stage";
            "S" = "StageUnstaged";
            "<c-s>" = "StageAll";
            "K" = "Untrack";
            "u" = "Unstage";
            "U" = "UnstageStaged";
            "$" = "CommandHistory";
            "Y" = "YankSelected";
            "<c-r>" = "RefreshBuffer";
            "<cr>" = "GoToFile";
            "<s-cr>" = "PeekFile";
            "<c-v>" = "VSplitOpen";
            "<c-x>" = "SplitOpen";
            "<c-t>" = "TabOpen";
            "{" = "GoToPreviousHunkHeader";
            "}" = "GoToNextHunkHeader";
            "[c" = "OpenOrScrollUp";
            "c" = "OpenOrScrollDown";
            "<c-k>" = "PeekUp";
            "<c-j>" = "PeekDown";
          };
        };
      };

      after = "";
    };
    "neoscroll.nvim" = {
      package = neoscroll-nvim;
      setupModule = "neoscroll";
      setupOpts = {
        cursor_scrolls_alone = true;
        easing_function = "quadratic";
        hide_cursor = true;
        respect_scrolloff = false;
        stop_eof = true;
      };
    };
    "toggleterm.nvim" = {
      package = toggleterm-nvim;
      setupModule = "toggleterm";
      setupOpts = {
        direction = "float";
      };
    };
    "flash.nvim" = {
      package = flash-nvim;
      setupModule = "flash";
      setupOpts = {};
    };
    "indent-blankline.nvim" = {
      package = indent-blankline-nvim;
      setupModule = "ibl";
      setupOpts = {
        exclude = {
          filetypes = ["dashboard"];
        };
      };
    };
    "yazi.nvim" = {
      package = yazi-nvim;
      setupModule = "yazi";
      setupOpts = {};
    };
  };
}
