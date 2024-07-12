{
  plugins.barbar = {
    lazyLoad.settings.event = "BufEnter";
    enable = true;
    settings = {
      auto_hide = 1;
      highlight_visible = false;
    };
  };
  plugins.lualine = {
    lazyLoad.settings.event = "BufEnter";
    enable = true;
    settings = {
      options = {
        globalstatus = true;
        disabled_filetypes = {
          statusline = ["alpha"];
          winbar = ["alpha"];
        };
      };
      sections = {
        lualine_a = ["mode"];
        lualine_b = [
          "branch"
          {
            __unkeyed-1 = "require'lsp-status'.status()";
            symbols = {
              error = " ";
              warn = " ";
              info = " ";
              hint = "󰝶 ";
            };
          }
        ];
        lualine_c = ["filename"];
        lualine_x = [
          {
            __unkeyed-1 = "diff";
            sources = ["diff_source()"];
            symbols = {
              added = " ";
              modified = "󰝤 ";
              removed = " ";
            };
          }
          {
            __unkeyed-1 = "filetype";
            icon_only = true;
          }
        ];
        lualine_y = [
          "progress"
          "location"
        ];
        lualine_z = ["' ' .. os.date('%a')"];
      };
      inactiveSections = {
        lualine_c = ["filename"];
        lualine_x = ["location"];
      };
    };
  };

  extraConfigLua = ''
    local lsp_status = require('lsp-status')
    lsp_status.register_progress()

    function diff_source()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed
        }
      end
    end

    function lsp_stat()
      if vim.lsp.get_clients() > 0 then
        require('lsp-status').status()
      end
    end
  '';
}
