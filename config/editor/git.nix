{
  lib,
  config',
  pkgs,
  mkDashDefault,
  ...
}: let
  adopure-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "adopure.nvim";
    version = "13.03.2025";

    src = pkgs.fetchFromGitHub {
      owner = "Willem-J-an";
      repo = "adopure.nvim";
      rev = "f6b7f76507eeca102375225d62f348e1e5ea8cad";
      hash = "sha256-vwolAocKKKvVeBc1bakpVW9yKlpu0iBy7UOs9hS2ihE=";
    };
    dependencies = with pkgs; [
      vimPlugins.telescope-nvim
      vimPlugins.plenary-nvim
    ];

    doCheck = false;
  };
in {
  vim = {
    lazy.plugins = with pkgs.vimPlugins; {
      "git-blame.nvim" = mkDashDefault {
        package = git-blame-nvim;
        setupModule = "gitblame";
      };
      "gh.nvim" = mkDashDefault {
        package = gh-nvim;
        setupModule = "litee.gh";
      };
      "adopure.nvim" = mkDashDefault {
        package = adopure-nvim;
      };
    };
    git = mkDashDefault {
      gitsigns = {
        enable = true;
      };
      git-conflict = {
        enable = true;
      };
      gitlinker-nvim = {
        enable = true;
      };
      neogit = {
        enable = true;
        setupOpts = {
          use_default_keymaps = false;
          mappings = lib.mkIf config'.useDefaultKeybinds {
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
      };
    };
  };
}
