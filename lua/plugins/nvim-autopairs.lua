return {
  'windwp/nvim-autopairs',
  enabled = false,
  event = 'InsertEnter',
  keys = '<M-a>',
  opts = {
    break_undo = false,
    fast_wrap = {
      keys = 'wertyuiopzxcvbnmasdfghjkl',
    },
  },
  config = function(_, opts)
    local autopairs = require('nvim-autopairs')
    autopairs.setup(opts)

    vim.keymap.set({ 'n', 'i' }, '<M-a>', function()
      if autopairs.state.disabled == true then
        autopairs.enable()
        vim.notify('Enabled autopairs')
      else
        autopairs.disable()
        vim.notify('Disabled autopairs')
      end
    end, { desc = 'Toggle auto pairs' })
  end,
}
