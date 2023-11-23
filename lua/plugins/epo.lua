return {
  'nvimdev/epo.nvim',
  enabled = false,
  opts = {
    fuzzy = false,
    -- increase this value can aviod trigger complete when delete character.
    debounce = 50,
    -- when completion confrim auto show a signature help floating window.
    signature = false,
    -- extend vscode format snippet json files. like rust.json/typescriptreact.json/zig.json
    snippet_path = nil,
  },
  config = function(_, opts)
    require('epo').setup(opts)
    vim.keymap.set('i', '<CR>', function()
      return vim.fn.pumvisible() == 1 and '<C-Y>' or '<CR>'
    end, { expr = true })
  end,
}
