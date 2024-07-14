{
  plugins.barbar = {
    enable = true;
    settings = {
      auto_hide = 1;
      highlight_visible = false;
    };
  };
  plugins.lualine = {
    enable = true;
    globalstatus = true;
    sections = {
      lualine_a = [ "mode" ];
      lualine_b = [
        "branch"
        # "diff"
        {
          name = "diagnostics";
          # name = "require'lsp-status'.status()";
          extraConfig = {
            sources = [ "nvim_lsp" ];
            symbols = {
              error = " ";
              warn = " ";
              info = " ";
              hint = "󰝶 ";
            };
          };
        }
      ];
      lualine_c = [ "filename" ];
      lualine_x = [
        {
          name = "diff";
          extraConfig = {
            # sources = [ "vim.b.gitsigns_status" ];
            sources = [ ''diff_source()'' ];
            #   ''function()
            #       local gitsigns = vim.b.gitsigns_status_dict
            #         if gitsigns then
            #          return {
            #            added = gitsigns.added,
            #            modified = gitsigns.changed,
            #            removed = gitsigns.removed,
            #          }
            #        end
            #      end''
            # ];
            symbols = {
              added = " ";
              modified = "󰝤 ";
              removed = " ";
            };
          };
        }
        {
          name = "filetype";
          extraConfig = {
            icon_only = true;
          };
        }
      ];
      lualine_y = [ "progress" "location" ];
      lualine_z = [ "' ' .. os.date('%a')" ];
    };
    inactiveSections = {
      lualine_c = [ "filename" ];
      lualine_x = [ "location" ];
    };
    disabledFiletypes = {
      statusline = [ "alpha" ];
      winbar = [ "alpha" ];
    };
  };

  extraConfigLua = ''
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
  '';
}
