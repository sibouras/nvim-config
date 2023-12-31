return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      changedelete = { text = '▎' },
      untracked = { text = '▎' },
    },
    -- base = 'FILE',
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      -- stylua: ignore start
      map({ 'n', 'v' }, '<leader>gs', ':Gitsigns stage_hunk<CR>', 'Stage Hunk')
      map({ 'n', 'v' }, '<leader>gr', ':Gitsigns reset_hunk<CR>', 'Reset Hunk')
      map('v', '<leader>gl', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, 'Stage Line')
      map('v', '<leader>gL', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, 'Reset Line')
      map('n', '<leader>gu', gs.undo_stage_hunk, 'Undo Stage Hunk')
      map('n', '<leader>gS', gs.stage_buffer, 'Stage Buffer')
      map('n', '<leader>gR', gs.reset_buffer, 'Reset Buffer')
      map('n', '<leader>gp', gs.preview_hunk, 'Preview Hunk')
      map('n', '<leader>gi', gs.preview_hunk_inline, 'Preview Hunk Inline')
      map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame Line')
      map('n', '<leader>gd', gs.diffthis, 'Diff This')
      map('n', '<leader>gD', function() gs.diffthis('~') end, 'Diff This ~')
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'GitSigns Select Hunk')
    end,
  },
}
