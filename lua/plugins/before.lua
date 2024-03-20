return {
  'bloznelis/before.nvim',
  enabled = true,
  config = function()
    local before = require('before')
    before.setup()

    -- Jump to previous entry in the edit history
    vim.keymap.set('n', '<C-h>', before.jump_to_last_edit, {})
    -- Jump to next entry in the edit history
    vim.keymap.set('n', '<C-l>', before.jump_to_next_edit, {})
    -- Move edit history to quickfix and open it (or telescope)
    vim.keymap.set('n', 'mo', before.show_edits_in_quickfix, {})
  end,
}
