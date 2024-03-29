local ccc_filetypes = { 'css', 'sass', 'less' }
return {
  {
    'mrshmllow/document-color.nvim', -- colorizer plugin for tailwindcss
    lazy = true,
  },
  {
    'uga-rosa/ccc.nvim',
    cmd = { 'CccPick', 'CccConvert', 'CccHighlighterToggle' },
    ft = ccc_filetypes,
    keys = {
      { '<leader>cp', '<Cmd>CccPick<CR>', desc = 'Ccc Pick' },
      { '<leader>ch', '<Cmd>CccHighlighterToggle<CR>', desc = 'Ccc Highlight Toggle' },
      { '<leader>co', '<Cmd>CccConvert<CR>', desc = 'Ccc Convert' },
    },
    config = function()
      local ccc = require('ccc')
      ccc.setup({
        default_color = '#40bfbf', -- recommended default color for hsl
        highlighter = {
          auto_enable = true,
          lsp = false,
          filetypes = ccc_filetypes,
        },
        inputs = {
          ccc.input.hsl,
          ccc.input.okhsl,
          ccc.input.rgb,
          ccc.input.cmyk,
        },
        mappings = {
          ['?'] = function()
            vim.api.nvim_echo({
              { 'i - Toggle input mode\n' },
              { 'o - Toggle output mode\n' },
              { 'a - Toggle alpha slider\n' },
              { 'g - Toggle palette\n' },
              { 'r - Reset mode\n' },
              { 'w - Go to next color in palette\n' },
              { 'b - Go to prev color in palette\n' },
              { 'l/d/,(1,5,10) - Increase slider\n' },
              { 'h/s/m,(1,5,10) - Decrease slider\n' },
              { '1-9 - Set slider value\n' },
            }, true, {})
          end,
        },
      })
    end,
  },
}
