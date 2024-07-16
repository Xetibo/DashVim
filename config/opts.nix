{ config, ... }: {
  globals = {
    fileencoding = "utf-8";
    number = true;
    showmode = true;
    spelllang = "en_us";
    shell = "fish";
    relativenumber = false;
    scrolloff = 5;
    scrolljump = 5;
    wrap = false;
    mapleader = " ";
    gitblame_enabled = false;
    clear_background = true;
  };

  opts = {
    foldenable = false;
    foldmethod = "manual";
    termguicolors = true;
    number = true;
    shell = "fish";
  };

  clipboard.register = "unnamedplus";
  autoGroups = {
    custom_theme = { };
    highlight_yank = { };
    resize = { };
    neotree = { };
  };
  autoCmd = [
    {
      desc = "Neotree directory";
      event = [ "BufEnter" ];
      group = "neotree";
      pattern = "*";
      callback = {
        __raw = ''function()
          if package.loaded["neo-tree"] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == "directory" then
              require("neo-tree")
            end
          end
        end'';
      };
    }
    {
      desc = "yank highlight";
      event = [ "TextYankPost" ];
      group = "highlight_yank";
      pattern = "*";
      callback = {
        __raw = ''function()
          vim.highlight.on_yank()
        end'';
      };
    }
    {
      desc = "Resize splits";
      event = [ "VimResized" ];
      group = "resize";
      pattern = "*";
      callback = {
        __raw = ''function()
          local current_tab = vim.fn.tabpagenr()
          vim.cmd("tabdo wincmd =")
          vim.cmd("tabnext " .. current_tab)
        end'';
      };
    }
  ];
}
