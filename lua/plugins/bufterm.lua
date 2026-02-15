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

    local shell = require('bufterm.terminal').Terminal:new({
      cmd = function()
        if vim.g.is_win then
          local flag = vim.opt.shellcmdflag:get()
          vim.opt.shellcmdflag = '--no-config-file -c'
          vim.schedule(function()
            vim.opt.shellcmdflag = flag
          end)
          return 'nu'
        end
        return vim.o.shell
      end,
      buflisted = false,
      termlisted = true, -- set this option to false if you treat this terminal as single independent terminal
    })

    local function get_term_win_info()
      -- Get a list of all visible windows with their information
      local windows = vim.fn.getwininfo()
      -- Iterate through each window and check if the window is a terminal
      for _, win_info in ipairs(windows) do
        if win_info.terminal == 1 then
          return win_info
        end
      end
    end

    -- switch to most recent terminal
    local recent_bufnr
    map({ 'n', 'i', 't' }, '<M-C-S-F7>', function() -- mapped <C-;> to <M-C-S-F7> with ahk
      local mode = vim.api.nvim_get_mode().mode
      if mode == 'i' then
        vim.cmd('stopinsert')
      end

      local term_win_info = get_term_win_info()
      -- if a terminal window is visible close it
      if term_win_info then
        recent_bufnr = term_win_info.bufnr
        vim.api.nvim_win_close(term_win_info.winid, false)
      elseif recent_bufnr == nil then
        shell:spawn()
        require('bufterm.ui').toggle_float(shell.bufnr)
      elseif require('bufterm.ui').toggle_float(recent_bufnr) then
        -- vim.cmd('BufTermEnter')
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
      local term_win_info = get_term_win_info()
      -- if a terminal window is visible close it
      if term_win_info then
        if term_win_info.winid ~= vim.fn.win_getid() then
          vim.api.nvim_win_close(term_win_info.winid, false)
        end
      end

      local cur_bufnr = vim.api.nvim_get_current_buf()
      if vim.bo.buftype == 'terminal' and get_most_recent_buffer() then
        recent_bufnr = cur_bufnr
        vim.cmd('b' .. get_most_recent_buffer())
      else
        if recent_bufnr == nil then
          shell:spawn()
        end
        vim.cmd('b' .. (recent_bufnr or shell.bufnr))
      end
    end, { desc = 'Enter terminal' })

    local height = 18
    map({ 'n', 't' }, '<F2>', function()
      local term_win_info = get_term_win_info()
      -- if terminal window is visible close it
      if term_win_info then
        recent_bufnr = term_win_info.bufnr
        -- save the height when closing a horizontal(winrow > 1) terminal
        -- winrow > 1 for a horizontal terminal
        if term_win_info.winrow > 1 then
          height = vim.api.nvim_win_get_height(term_win_info.winid)
        end
        vim.cmd.wincmd('p')
        vim.api.nvim_win_close(term_win_info.winid, false)
      else
        if recent_bufnr == nil then
          shell:spawn()
        end
        vim.cmd('botright sb' .. (recent_bufnr or shell.bufnr))
        vim.api.nvim_win_set_height(0, height)
      end
    end, { desc = 'Toggle horizontal terminal' })

    local width = 52
    map({ 'n', 't' }, '<F3>', function()
      local term_win_info = get_term_win_info()
      -- print(vim.inspect(term_win_info))
      -- if terminal window is visible close it
      if term_win_info then
        recent_bufnr = term_win_info.bufnr
        -- save the width when closing a vertical(winrow = 1) terminal
        if term_win_info.winrow == 1 then
          width = vim.api.nvim_win_get_width(term_win_info.winid)
        end
        vim.cmd.wincmd('p')
        vim.api.nvim_win_close(term_win_info.winid, false)
      else
        if recent_bufnr == nil then
          shell:spawn()
        end
        -- vim.cmd('vertical topleft sb' .. (recent_bufnr or shell.bufnr))
        vim.cmd('vertical botright sb' .. (recent_bufnr or shell.bufnr))
        vim.api.nvim_win_set_width(0, width)
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
