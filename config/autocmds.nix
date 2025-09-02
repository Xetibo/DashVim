{lib, ...}: {
  vim.augroups = [
    {name = "custom_theme ";}
    {name = "highlight_yank";}
    {name = "resize";}
    {name = "neotree";}
    {name = "filetypes";}
  ];
  vim.autocmds = [
    {
      desc = "Neotree directory";
      event = ["BufEnter"];
      group = "neotree";
      pattern = ["*"];
      callback =
        lib.generators.mkLuaInline
        /*
        lua
        */
        ''
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
    }
    {
      desc = "yank highlight";
      event = ["TextYankPost"];
      group = "highlight_yank";
      pattern = ["*"];
      callback =
        lib.generators.mkLuaInline
        /*
        lua
        */
        ''
          function()
                    vim.highlight.on_yank()
                  end'';
    }
    {
      desc = "Resize splits";
      event = ["VimResized"];
      group = "resize";
      pattern = ["*"];
      callback =
        lib.generators.mkLuaInline
        /*
        lua
        */
        ''
          function()
            local current_tab = vim.fn.tabpagenr()
            vim.cmd("tabdo wincmd =")
            vim.cmd("tabnext " .. current_tab)
          end'';
    }
    {
      desc = "Disable lsp-lines by default";
      event = ["BufEnter"];
      group = "filetypes";
      pattern = ["*"];
      callback =
        lib.generators.mkLuaInline
        /*
        lua
        */
        ''
          function()
            vim.diagnostic.config({ virtual_lines = false })
          end'';
    }
    {
      desc = "Add typst as filetype";
      event = ["BufEnter"];
      group = "filetypes";
      pattern = ["*"];
      callback =
        lib.generators.mkLuaInline
        /*
        lua
        */
        ''
          function()
            vim.filetype.add({
            	extension = {
            		typst = "typst",
            		typ = "typst",
            	},
            })
          end'';
    }
    {
      desc = "Init lua";
      event = ["BufEnter"];
      group = "filetypes";
      pattern = ["*.lua"];
      callback =
        lib.generators.mkLuaInline
        /*
        lua
        */
        ''
          function()
            vim.opt_local.expandtab = true
            vim.opt_local.softtabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.formatoptions:append({ c = true, r = true, o = true, q = true }) 
          end'';
    }
  ];
}
