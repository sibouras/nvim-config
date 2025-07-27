return {
  'lewis6991/gitsigns.nvim',
  event = 'LazyFile',
  opts = {
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      changedelete = { text = '▎' },
      untracked = { text = '▎' },
    },
    preview_config = {
      border = 'rounded',
    },
    diffthis = {
      split = 'belowright',
    },
    -- base = 'FILE',
    on_attach = function(buffer)
      if vim.fn.bufname('#'):match('LOCAL') then
        -- Don't attach in mergetool
        return false
      end

      local gitsigns = require('gitsigns')

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      -- stylua: ignore start
      map({ 'n', 'v' }, '<leader>gs', gitsigns.stage_hunk, 'Stage Hunk')
      map({ 'n', 'v' }, '<leader>gr', gitsigns.reset_hunk, 'Reset Hunk')
      map('v', '<leader>gl', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, 'Stage Line')
      map('v', '<leader>gL', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, 'Reset Line')
      map('n', '<leader>gS', gitsigns.stage_buffer, 'Stage Buffer')
      map('n', '<leader>gR', gitsigns.reset_buffer, 'Reset Buffer')
      map('n', '<leader>gp', gitsigns.preview_hunk, 'Preview Hunk')
      map('n', '<leader>gi', gitsigns.preview_hunk_inline, 'Preview Hunk Inline')
      map('n', '<leader>gb', function() gitsigns.blame_line({ full = true }) end, 'Blame Line')
      map('n', '<leader>gd', gitsigns.diffthis, 'Diff This')
      map('n', '<leader>gD', function() gitsigns.diffthis('~') end, 'Diff This ~')
      map('n', '<leader>gQ', function() gitsigns.setqflist('all') end, 'Set qflist all')
      map('n', '<leader>gq', gitsigns.setqflist, 'Set qflist')
      -- Toggles
      map('n', '<leader>gB', gitsigns.toggle_current_line_blame, 'Toggle Blame Line')
      map('n', '<leader>gt', gitsigns.toggle_deleted, 'Toggle Deleted')
      map('n', '<leader>gw', gitsigns.toggle_word_diff, 'Toggle Word Diff')
      -- Text object
      map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'GitSigns Select Hunk')
    end,
  },
}
