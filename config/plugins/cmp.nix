{
  lib,
  inputs,
  config',
  ...
}:
{
  #extraPlugins = [
  #  inputs.blink.packages."x86_64-linux".blink-cmp
  #];
  #extraConfigLua = ''
  #  require("blink.cmp").setup({
  #    keymap = {
  #      show = '<C-space>',
  #      hide = '<C-e>',
  #      accept = '<Enter>',
  #      select_and_accept = {'<Enter>'},
  #      select_prev = { '<S-Tab>', '<C-p>' },
  #      select_next = { '<Tab>', '<C-n>' },

  #      show_documentation = '<C-space>',
  #      hide_documentation = '<C-space>',
  #      scroll_documentation_up = '<C-b>',
  #      scroll_documentation_down = '<C-f>',

  #      snippet_forward = '<Tab>',
  #      snippet_backward = '<S-Tab>',
  #    },
  #    trigger = {
  #      sources = {
  #          -- similar to nvim-cmp's sources, but we point directly to the source's lua module
  #          -- multiple groups can be provided, where it'll fallback to the next group if the previous
  #          -- returns no completion items
  #          -- WARN: This API will have breaking changes during the beta
  #          providers = {
  #            { 'blink.cmp.sources.lsp', name = 'LSP' },
  #            { 'blink.cmp.sources.path', name = 'Path', score_offset = 3 },
  #            --{ 'blink.cmp.sources.snippets', name = 'Snippets', score_offset = -3 },
  #            { 'blink.cmp.sources.buffer', name = 'Buffer', fallback_for = { 'LSP' } },
  #          },
  #          -- WARN: **For reference only** to see what options are available. **See above for the default config**
  #          providers = {
  #            -- all of these properties work on every source
  #            {
  #                'blink.cmp.sources.lsp',
  #                name = 'LSP',
  #                keyword_length = 0,
  #                score_offset = 0,
  #                trigger_characters = { 'f', 'o', 'o' },
  #            },
  #            -- the following two sources have additional options
  #            {
  #              'blink.cmp.sources.path',
  #              name = 'Path',
  #              score_offset = 3,
  #              keyword_length = 4,
  #              opts = {
  #                trailing_slash = false,
  #                label_trailing_slash = true,
  #                get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
  #                show_hidden_files_by_default = true,
  #              }
  #            },
  #            {
  #              'blink.cmp.sources.snippets',
  #              name = 'Snippets',
  #              score_offset = -3,
  #              -- similar to https://github.com/garymjr/nvim-snippets
  #              opts = {
  #                friendly_snippets = true,
  #                search_paths = { vim.fn.stdpath('config') .. '/snippets' },
  #                global_snippets = { 'all' },
  #                extended_filetypes = {},
  #                ignored_filetypes = {},
  #              },
  #            },
  #            {
  #              'blink.cmp.sources.buffer',
  #              name = 'Buffer',
  #              fallback_for = { 'LSP' },
  #              keyword_length = 4,
  #            }
  #          }
  #        },
  #    },
  #    windows = {
  #      autocomplete = {
  #        border = 'rounded',
  #      },
  #      documentation = {
  #        border = 'rounded',
  #        auto_show = true,
  #      },
  #    },
  #  }) 
  #'';
  plugins = {
    # once again fsharp blocks me from using an awesome plugin
    # this langauge is starting to get on my nerves.
    cmp = lib.mkIf config'.useDefaultCmpConfig {
      enable = true;
      settings = {
        autoEnableSources = true;
        experimental = {
          ghost_text = true;
        };
        performance = {
          debounce = 10;
          fetchingTimeout = 200;
          maxViewEntries = 30;
        };
        snippet = {
          expand = "luasnip";
        };
        formatting = {
          fields = [
            "kind"
            "abbr"
            "menu"
          ];
        };
        sources = [
          {
            name = "nvim_lsp";
          }
          {
            name = "buffer";
            keyword_length = 5;
          }
          {
            name = "async_path";
            keyword_length = 5;
          }
          {
            name = "luasnip";
            keyword_length = 3;
          }
        ];

        window = {
          completion = {
            border = "rounded";
            scrollbar = false;
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
          };
          documentation = {
            border = "rounded";
            scrollbar = false;
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
          };
        };
        mapping = {
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = false })";
          "<S-CR>" = ''
            cmp.mapping.confirm({
                        behavior =  cmp.ConfirmBehavior.Replace,
                        select = false,
                      })'';
          "<Tab>" = ''
            cmp.mapping(function(fallback)
                        if cmp.visible() then
                          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                        else
                          fallback()
                        end
                      end, { "i", "s" }),
                      ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                        else
                          fallback()
                        end
                      end, {
                        "i",
                        "s",
                      })'';
          "<C-j>" = ''
            cmp.mapping(function(fallback)
                        if luasnip.expandable() then
                          luasnip.expand()
                        elseif luasnip.expand_or_jumpable() then
                          luasnip.expand_or_jump()
                        else
                          fallback()
                        end
                      end, {
                        "i",
                        "s",
                      })'';
          "<C-k>" = ''
            cmp.mapping(function(fallback)
                        if luasnip.expand_or_jumpable(-1) then
                          luasnip.jump(-1)
                        else
                          fallback()
                        end
                      end, {
                        "i",
                        "s",
                      })'';
        };
      };
    };
    cmp-async-path = {
      enable = true;
    };
    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
      };
    };
    cmp_luasnip = {
      enable = true;
    };
    cmp-nvim-lsp = {
      enable = true;
    };
  };

  extraConfigLua = ''
    luasnip = require("luasnip")
    cmp_kinds = {
      Text = "󰊄",
      Method = "",
      Function = "󰡱",
      Constructor = "",
      Field = "",
      Variable = "󱀍",
      Class = "",
      Interface = "",
      Module = "󰕳",
      Property = "",
      Unit = "",
      Value = "",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "",
      Event = "",
      Operator = "",
      TypeParameter = "",
    }
    require("cmp").setup({
      formatting = {
        fields = { "kind", "abbr" },
        format = function(_, vim_item)
          vim_item.kind = cmp_kinds[vim_item.kind] or ""
          return vim_item
        end,
      },
    })
  '';
}
