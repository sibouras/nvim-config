return {
  'wfxr/minimap.vim',
  enabled = false,
  keys = {
    { '<leader>mm', ':MinimapToggle<CR>', desc = 'Minimap Toggle', silent = true },
    { '<leader>mr', ':MinimapRefresh<CR>', desc = 'Minimap Refresh', silent = true },
  },
  init = function()
    vim.g.minimap_width = 20
    vim.g.minimap_base_highlight = 'Normal'
    vim.g.minimap_block_filetypes = { 'fugitive', 'tagbar', 'BufTerm' }

    vim.api.nvim_create_autocmd('FileType', {
      desc = 'close minimap with q',
      group = vim.api.nvim_create_augroup('MyGroup_minimap', { clear = true }),
      pattern = 'minimap',
      callback = function()
        vim.keymap.set('n', 'q', '<Cmd>wincmd w | MinimapClose<CR>', { buffer = true })
      end,
    })
  end,
}
