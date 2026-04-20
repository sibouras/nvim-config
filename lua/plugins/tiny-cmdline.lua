return {
  'rachartier/tiny-cmdline.nvim',
  init = function()
    vim.o.cmdheight = 0
    vim.g.tiny_cmdline = {
      menu_col_offset = 0,
      on_reposition = require('tiny-cmdline').adapters.blink,
    }
  end,
}
