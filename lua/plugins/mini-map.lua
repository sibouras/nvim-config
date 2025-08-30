return {
  'nvim-mini/mini.map',
  keys = {
    { '<leader>mm', '<Cmd>lua MiniMap.toggle()<CR>', desc = 'MiniMap Toggle' },
    { '<leader>mf', desc = 'MiniMap Focus (Toggle)' },
  },
  opts = function()
    local minimap = require('mini.map')

    for _, key in ipairs({ 'n', 'N', '*', '#' }) do
      vim.keymap.set('n', key, key .. 'zv<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>')
    end

    vim.keymap.set('n', '<leader>mr', '<Cmd>lua MiniMap.refresh()<CR>', { desc = 'MiniMap Refresh' })
    vim.keymap.set('n', '<leader>ms', '<Cmd>lua MiniMap.toggle_side()<CR>', { desc = 'MiniMap Side (toggle})' })

    local is_window_open = function()
      local cur_win_id = minimap.current.win_data[vim.api.nvim_get_current_tabpage()]
      return cur_win_id ~= nil and vim.api.nvim_win_is_valid(cur_win_id)
    end

    vim.keymap.set('n', '<leader>mf', function()
      if not is_window_open() then
        minimap.open()
      end
      vim.schedule(function()
        minimap.toggle_focus()
      end)
    end, { desc = 'MiniMap Focus (Toggle)' })

    return {
      integrations = {
        minimap.gen_integration.builtin_search(),
        minimap.gen_integration.gitsigns(),
        minimap.gen_integration.diagnostic(),
      },
      symbols = {
        -- Encode symbols. See `:h MiniMap.config` for specification and
        -- `:h MiniMap.gen_encode_symbols` for pre-built ones.
        -- Default: solid blocks with 3x2 resolution.
        encode = minimap.gen_encode_symbols.dot('4x2'),
      },
      window = {
        show_integration_count = false,
      },
    }
  end,
}
