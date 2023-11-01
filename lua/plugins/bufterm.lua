return {
  'boltlessengineer/bufterm.nvim',
  enabled = true,
  event = { 'TermOpen' },
  keys = {
    { mode = { 'n', 't' }, '<C-t>' },
    { mode = { 'n', 't' }, '<F1>' },
    { mode = { 'n', 't' }, '<F2>' },
  },
  opts = {
    terminal = {
      buflisted = false,
    },
  },
  config = function(_, opts)
    require('bufterm').setup(opts)

    vim.api.nvim_create_autocmd({ 'FileType' }, {
      desc = 'add BufTerm Next/Prev mappings',
      pattern = 'BufTerm',
      group = vim.api.nvim_create_augroup('MyGroup_BufTerm', { clear = true }),
      callback = function()
        vim.keymap.set({ 'n', 't' }, '<C-n>', '<Cmd>BufTermNext<CR>', { buffer = true, desc = 'Next Terminal' })
        vim.keymap.set({ 'n', 't' }, '<C-p>', '<Cmd>BufTermPrev<CR>', { buffer = true, desc = 'Prev Terminal' })
      end,
    })

    local nu = require('bufterm.terminal').Terminal:new({
      cmd = 'nu --no-std-lib',
      buflisted = false,
      termlisted = true, -- set this option to false if you treat this terminal as single independent terminal
    })

    -- switch to most recent terminal
    local recent_bufnr
    vim.keymap.set({ 'n', 't' }, '<C-t>', function()
      local cur_bufnr = vim.api.nvim_get_current_buf()
      if vim.bo.buftype == 'terminal' then
        recent_bufnr = cur_bufnr
        vim.cmd('close')
      elseif recent_bufnr == nil then
        nu:spawn()
        require('bufterm.ui').toggle_float(nu.bufnr)
      elseif require('bufterm.ui').toggle_float(recent_bufnr) then
        vim.cmd('BufTermEnter')
      end
    end, { desc = 'Toggle floating terminal' })

    vim.keymap.set({ 'n', 't' }, '<F1>', function()
      local cur_bufnr = vim.api.nvim_get_current_buf()
      if vim.bo.buftype == 'terminal' then
        recent_bufnr = cur_bufnr
        vim.cmd('close')
      elseif recent_bufnr == nil then
        nu:spawn()
        vim.cmd('b' .. nu.bufnr)
      else
        vim.cmd('b' .. recent_bufnr)
      end
    end, { desc = 'Enter terminal' })

    vim.keymap.set({ 'n', 't' }, '<F2>', function()
      local cur_bufnr = vim.api.nvim_get_current_buf()
      if vim.bo.buftype == 'terminal' then
        recent_bufnr = cur_bufnr
        vim.cmd('close')
      elseif recent_bufnr == nil then
        nu:spawn()
        vim.cmd('sb' .. nu.bufnr)
      else
        vim.cmd('sb' .. recent_bufnr)
      end
    end, { desc = 'Toggle horizontal terminal' })

    vim.api.nvim_create_autocmd('User', {
      pattern = '__BufTermClose',
      callback = function()
        recent_bufnr = nil
      end,
    })
  end,
}
