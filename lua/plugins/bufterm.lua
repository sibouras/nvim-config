return {
  'boltlessengineer/bufterm.nvim',
  enabled = true,
  event = { 'TermOpen' },
  keys = {
    { mode = { 'n', 'i', 't' }, '<M-C-S-F7>', desc = 'Toggle floating terminal' },
    { mode = { 'n', 't' }, '<F1>', desc = 'Enter terminal' },
    { mode = { 'n', 't' }, '<F2>', desc = 'Toggle horizontal terminal' },
    { mode = { 'n', 't' }, '<F3>', desc = 'Toggle vertical terminal' },
  },
  opts = {
    terminal = {
      buflisted = false,
    },
  },
  config = function(_, opts)
    require('bufterm').setup(opts)
    local map = vim.keymap.set

    vim.api.nvim_create_autocmd({ 'FileType' }, {
      desc = 'add BufTerm Next/Prev mappings',
      pattern = 'BufTerm',
      group = vim.api.nvim_create_augroup('MyGroup_BufTerm', { clear = true }),
      callback = function()
        map({ 'n', 't' }, '<C-n>', '<Cmd>BufTermNext<CR>', { buffer = true, desc = 'Next Terminal' })
        map({ 'n', 't' }, '<C-p>', '<Cmd>BufTermPrev<CR>', { buffer = true, desc = 'Prev Terminal' })
      end,
    })

    local nu = require('bufterm.terminal').Terminal:new({
      cmd = function()
        local flag = vim.opt.shellcmdflag:get()
        vim.opt.shellcmdflag = '--no-config-file -c'
        vim.schedule(function()
          vim.opt.shellcmdflag = flag
        end)
        return 'nu --no-std-lib'
      end,
      buflisted = false,
      termlisted = true, -- set this option to false if you treat this terminal as single independent terminal
    })

    -- switch to most recent terminal
    local recent_bufnr
    map({ 'n', 'i', 't' }, '<M-C-S-F7>', function() -- mapped <C-;> to <M-C-S-F7> with ahk
      local mode = vim.api.nvim_get_mode().mode
      if mode == 'i' then
        vim.cmd('stopinsert')
      end

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

    local function get_most_recent_buffer()
      -- Get a list of all listed buffers
      local listed_buffers = {}
      for _, bufnr in ipairs(vim.fn.getbufinfo({ windows = vim.fn.winnr(), buflisted = 1 })) do
        table.insert(listed_buffers, bufnr.bufnr)
      end
      -- Sort the listed buffers by access time
      table.sort(listed_buffers, function(a, b)
        return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
      end)
      return listed_buffers[1]
    end

    map({ 'n', 't' }, '<F1>', function()
      local cur_bufnr = vim.api.nvim_get_current_buf()
      if vim.bo.buftype == 'terminal' then
        recent_bufnr = cur_bufnr
        vim.cmd('b' .. get_most_recent_buffer())
        vim.schedule(function()
          -- Terminal-mode forces these local options so i reset them here, :h terminal-input
          vim.opt_local.cursorline = true
          vim.opt_local.scrolloff = 4
          vim.opt_local.sidescrolloff = 10
        end)
      elseif recent_bufnr == nil then
        nu:spawn()
        vim.cmd('b' .. nu.bufnr)
      else
        vim.cmd('b' .. recent_bufnr)
      end
    end, { desc = 'Enter terminal' })

    map({ 'n', 't' }, '<F2>', function()
      local cur_bufnr = vim.api.nvim_get_current_buf()
      if vim.bo.buftype == 'terminal' then
        recent_bufnr = cur_bufnr
        vim.cmd('close')
      elseif recent_bufnr == nil then
        nu:spawn()
        vim.cmd('sb' .. nu.bufnr)
        if type(vim.g.termheight) == 'number' and vim.g.termheight > 0 then
          vim.cmd('resize' .. vim.g.termheight)
        end
      else
        vim.cmd('sb' .. recent_bufnr)
        if type(vim.g.termheight) == 'number' and vim.g.termheight > 0 then
          vim.cmd('resize' .. vim.g.termheight)
        end
      end
    end, { desc = 'Toggle horizontal terminal' })

    map({ 'n', 't' }, '<F3>', function()
      local cur_bufnr = vim.api.nvim_get_current_buf()
      if vim.bo.buftype == 'terminal' then
        recent_bufnr = cur_bufnr
        vim.cmd('close')
      elseif recent_bufnr == nil then
        nu:spawn()
        vim.cmd('vertical sb' .. nu.bufnr)
        if type(vim.g.termwidth) == 'number' and vim.g.termwidth > 0 then
          vim.cmd('vertical resize' .. vim.g.termwidth)
        end
      else
        vim.cmd('vertical sb' .. recent_bufnr)
        if type(vim.g.termwidth) == 'number' and vim.g.termwidth > 0 then
          vim.cmd('vertical resize' .. vim.g.termwidth)
        end
      end
    end, { desc = 'Toggle vertical terminal' })

    vim.api.nvim_create_autocmd('User', {
      pattern = '__BufTermClose',
      callback = function()
        recent_bufnr = nil
      end,
    })
  end,
}
