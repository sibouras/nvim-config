return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  keys = '<M-a>',
  opts = {
    break_undo = false,
    fast_wrap = {},
  },
  config = function(_, opts)
    local autopairs = require('nvim-autopairs')
    autopairs.setup(opts)

    vim.keymap.set({ 'n', 'i' }, '<M-a>', function()
      if autopairs.state.disabled == true then
        autopairs.enable()
        print('Enabled autopairs')
      else
        autopairs.disable()
        print('Disabled autopairs')
      end
    end, { desc = 'Toggle auto pairs' })
  end,
}
