return {
  'RRethy/vim-illuminate',
  event = 'LazyFile',
  config = function()
    require('illuminate').configure({
      -- providers: provider used to get references in the buffer, ordered by priority
      providers = { 'lsp', 'treesitter' },
      -- delay: delay in milliseconds
      delay = 200,
      -- filetypes_denylist: filetypes to not illuminate when using regex, this overrides filetypes_allowlist
      filetypes_denylist = { 'dirvish', 'fugitive' },
      -- filetypes_allowlist: filetypes to illuminate, this is overriden by filetypes_denylist
      filetypes_allowlist = {},
      -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
      modes_denylist = {},
      -- modes_allowlist: modes to illuminate, this is overriden by modes_denylist
      modes_allowlist = {},
      -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
      -- Only applies to the 'regex' provider
      -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
      providers_regex_syntax_denylist = {},
      -- providers_regex_syntax_allowlist: syntax to illuminate, this is overriden by providers_regex_syntax_denylist
      -- Only applies to the 'regex' provider
      -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
      providers_regex_syntax_allowlist = {},
      -- under_cursor: whether or not to illuminate under the cursor
      under_cursor = true,
      -- large_file_cutoff: number of lines at which to use large_file_config
      -- The `under_cursor` option is disabled when this cutoff is hit
      large_file_cutoff = 1000,
      -- large_file_config: config to use for large files (based on large_file_cutoff).
      -- Supports the same keys passed to .configure
      -- If nil, vim-illuminate will be disabled for large files.
      large_file_overrides = {
        providers = { 'lsp' },
        delay = 200,
      },
      -- min_count_to_highlight: minimum number of matches required to perform highlighting
      -- min_count_to_highlight = 1,
      -- case_insensitive_regex: sets regex case sensitivity
      case_insensitive_regex = false,
    })

    local map = vim.keymap.set

    -- turn off highlighting for the buffer but still calculate references for
    -- <M-n> and <M-N>
    map('n', '<leader>ui', function()
      require('illuminate').toggle_visibility_buf()
    end, { desc = 'Toggle Illuminate' })

    map({ 'n', 'v' }, '<M-n>', '<cmd>lua require"illuminate".goto_next_reference()<CR>')
    map({ 'n', 'v' }, '<M-N>', '<cmd>lua require"illuminate".goto_prev_reference()<CR>')
  end,
}
