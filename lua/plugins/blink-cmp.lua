return {
  'saghen/blink.cmp',
  -- use a release tag to download pre-built binaries
  version = '*',
  event = { 'InsertEnter' },
  opts = {
    keymap = {
      preset = 'none',
      ['<M-C-S-F5>'] = { 'show', 'show_documentation', 'hide_documentation' }, -- mapped to control+space in terminal
      ['<C-c>'] = { 'cancel', 'fallback' },
      ['<C-e>'] = { 'cancel', 'fallback' },
      ['<C-y>'] = { 'select_and_accept', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-n>'] = { 'show', 'select_next', 'fallback_to_mappings' },
      ['<C-p>'] = { 'show', 'select_prev', 'fallback_to_mappings' },
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-b>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },
    cmdline = {
      enabled = true,
      keymap = {
        preset = 'cmdline',
        ['<M-C-S-F5>'] = { 'show' },
        ['<C-c>'] = { 'cancel', 'fallback' },
        ['<Down>'] = { 'accept', 'fallback' },
      },
      completion = {
        menu = {
          auto_show = false,
          draw = {
            columns = { { 'label', gap = 1 } }, -- remove icons
          },
        },
      },
    },
    snippets = { preset = 'luasnip' },
    signature = {
      enabled = true,
      window = { border = 'rounded' },
    },
    completion = {
      accept = {
        dot_repeat = false, -- fix neovide cursor jump
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 100,
        window = { border = 'rounded' },
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = true,
        },
      },
    },
  },
}
