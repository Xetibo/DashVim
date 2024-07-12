{config', ...}: {
  plugins.alpha = {
    enable = true;
    layout = [
      {
        type = "padding";
        val = 5;
      }
      {
        opts = {
          hl = "Include";
          position = "center";
        };
        type = "text";
        val = config'.alphaPicture;
      }
      {
        type = "padding";
        val = 2;
      }
      {
        type = "group";
        val = let
          mkButton = shortcut: cmd: val: hl: {
            type = "button";
            inherit val;
            on_press = {
              __raw = "function() ${cmd} end";
            };
            opts = {
              inherit hl;
              keymap = [
                "n"
                shortcut
                "<CMD>lua ${cmd} <CR>"
                {}
              ];
              shortcut = shortcut;
              position = "center";
              cursor = 0;
              width = 40;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          };
        in [
          (mkButton "f" "require('telescope.builtin').find_files({hidden = true})" " Find File" "Keyword")
          (mkButton "c" "require('telescope.builtin').oldfiles({hidden = true})" " Previous Files" "Keyword")
          (mkButton "y" "require('yazi').yazi()" " Yazi" "Keyword")
          (mkButton "p" "require('telescope').extensions.project.project{}" "󰺄 Projects" "Keyword")
          (mkButton "t" "require('telescope').extensions.zoxide.list{}" " Zoxide" "Keyword")
          (mkButton "q" "vim.cmd('qa')" "⏻ Quit Neovim" "Keyword")
        ];
      }
      {
        type = "padding";
        val = 2;
      }
      {
        opts = {
          hl = "Type";
          position = "center";
        };
        type = "text";
        val = "https://github.com/Xetibo/DashVim";
      }
    ];
  };
}
