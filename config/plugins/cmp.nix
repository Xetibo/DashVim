{
  lib,
  inputs,
  config',
  pkgs,
  ...
}:
{
  extraPlugins = with pkgs.vimPlugins; [
    blink-cmp
  ];
  extraConfigLua = ''
    require("blink.cmp").setup({
      keymap = {
        ['<C-space>'] = {'show', 'fallback'},
        ['<C-e>'] = {'hide', 'fallback'},
        ['<Enter>'] = {'accept', 'select_and_accept', 'fallback'},
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
      trigger = {
        sources = {
          providers = {
            { 'blink.cmp.sources.lsp', name = 'LSP' },
            { 'blink.cmp.sources.path', name = 'Path', score_offset = 3 },
            --{ 'blink.cmp.sources.snippets', name = 'Snippets', score_offset = -3 },
            { 'blink.cmp.sources.buffer', name = 'Buffer', fallback_for = { 'LSP' } },
          },
        },
      },
      windows = {
        autocomplete = {
          border = 'rounded',
          winhighlight = 'Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        },
        documentation = {
          border = 'rounded',
          winhighlight = 'Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
          auto_show = true,
        },
        ghost_text = {
          enabled = false,
        },
      },
    }) 
  '';
}
