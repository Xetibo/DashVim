{ pkgs, ... }:
{
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
    mkdp_auto_start = true;
    loaded_netrw = true;
    loaded_netrwPlugin = true;
    autoformat = false;
    mkdp_browser = "${pkgs.firefox}/bin/firefox";
    neovide_refresh_rate = 180;
    neovide_refresh_rate_idle = 5;
    neovide_hide_mouse_when_typing = true;
    "fsharp#workspace_mode_peek_deep_level" = 100;
    "fsharp#exclude_project_directories" = [ "paket-files" ];
    "fsharp#automatic_workspace_init" = 0;
    "fsharp#fsautocomplete_command" = [
      "fsautocomplete"
      "--adaptive-lsp-server-enabled"
      "--project-graph-enabled"
      "--use-fcs-transparent-compiler"
    ];
    swapfile = false;
  };

  opts = {
    guifont = "JetBrainsMono Nerd Font:h14";
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
    filetypes = { };
  };
  autoCmd = [
    {
      desc = "Haskell mappings";
      event = [ "FileType" ];
      group = "filetypes";
      pattern = "haskell";
      callback = {
        __raw = ''
          function()
                    local ht = require('haskell-tools')
                    local bufnr = vim.api.nvim_get_current_buf()
                    vim.keymap.set('n', '<leader>cE', ht.hoogle.hoogle_signature, {desc = "hoogle signature", buffer = bufnr})
                    -- Evaluate all code snippets
                    vim.keymap.set('n', '<leader>cS', ht.lsp.buf_eval_all, {desc = "evaluate", buffer = bufnr})
                  end'';
      };
    }
    {
      desc = "Neotree directory";
      event = [ "BufEnter" ];
      group = "neotree";
      pattern = "*";
      callback = {
        __raw = ''
          function()
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
        __raw = ''
          function()
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
        __raw = ''
          function()
                    local current_tab = vim.fn.tabpagenr()
                    vim.cmd("tabdo wincmd =")
                    vim.cmd("tabnext " .. current_tab)
                  end'';
      };
    }
    {
      desc = "Disable lsp-lines by default";
      event = [ "BufEnter" ];
      group = "filetypes";
      pattern = "*";
      callback = {
        __raw = ''
          function()
                    vim.diagnostic.config({ virtual_lines = false })
                  end'';
      };
    }
    {
      desc = "Add typst as filetype";
      event = [ "BufEnter" ];
      group = "filetypes";
      pattern = "*";
      callback = {
        __raw = ''
          function()
                    vim.filetype.add({
                    	extension = {
                    		typst = "typst",
                    		typ = "typst",
                    	},
                    })
                  end'';
      };
    }
    {
      desc = "Init lua";
      event = [ "BufEnter" ];
      group = "filetypes";
      pattern = "*.lua";
      callback = {
        __raw = # lua
          ''
            function()
              vim.opt_local.expandtab = true
              vim.opt_local.softtabstop = 4
              vim.opt_local.shiftwidth = 4
              vim.opt_local.formatoptions:append({ c = true, r = true, o = true, q = true }) 
            end'';
      };
    }
    {
      desc = "Init Overseer";
      event = [ "BufEnter" ];
      group = "filetypes";
      pattern = "*";
      callback = {
        __raw = ''
          function()
              require("overseer").setup()
          end'';
      };
    }
  ];
}
