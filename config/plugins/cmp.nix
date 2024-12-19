{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    blink-cmp
  ];
  extraConfigLua = ''
    require("blink.cmp").setup({
      keymap = {
        ['<C-space>'] = {'show', 'fallback'},
        ['<C-e>'] = {'hide', 'fallback'},
        ['<Enter>'] = {'select_and_accept', 'accept',  'fallback'},
        ['<S-Tab>'] = {'select_prev', 'fallback'},
        ['<Tab>'] = {'select_next', 'fallback'},
        ['<C-b>'] = {'scroll_documentation_up', 'fallback'},
        ['<C-f>'] = {'scroll_documentation_down', 'fallback'}
      },
      highlight = {
        use_nvim_cmp_as_default = true,
      },
      accept = {
        auto_brackets = { enabled = true }
      },
      sources = {
        completion = {
          enabled_providers = { 'lsp', 'path', 'buffer' },
        },
        providers = {
          lsp = { module = 'blink.cmp.sources.lsp', name = 'lsp', enabled = true },
          path = { module = 'blink.cmp.sources.path', name = 'path', min_keyword_length = 3, enabled = true, score_offset = -10 },
          buffer = { module = 'blink.cmp.sources.buffer', name = 'buffer', min_keyword_length = 5, fallback_for = { }, enabled = true, score_offset = -10 },
        },
      },
      completion = {
        menu = {
          border = 'rounded',
          winhighlight = 'Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        },
        documentation = {
          auto_show = true,
          window = {
            border = 'rounded',
            winhighlight = 'Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
          },
        },
        ghost_text = {
          enabled = true,
        },
      },
    }) 
  '';
}
