return {
  'echasnovski/mini.bracketed',
  event = 'VeryLazy',
  opts = {
    file = { suffix = 'r', options = { wrap = false } },
    buffer = { suffix = 'b', options = { wrap = false } },
    oldfile = { suffix = 'o', options = { wrap = false } },
    conflict = { suffix = 'x', options = {} },
    location = { suffix = 'l', options = {} },
    yank = { suffix = 'y', options = { wrap = false } },
    window = { suffix = 'w', options = {} },
    -- using these with Repeat movement with ; and ,
    comment = { suffix = 'c', options = { add_to_jumplist = true } },
    indent = { suffix = 'i', options = { add_to_jumplist = true } },
    treesitter = { suffix = 't', options = { add_to_jumplist = true } },
    -- disable these
    diagnostic = { suffix = '', options = {} },
    jump = { suffix = '', options = {} },
    quickfix = { suffix = '', options = {} },
    undo = { suffix = '', options = {} },
  },
  config = function(_, opts)
    require('mini.bracketed').setup(opts)

    -- only regions from mapped put operations will be used for first advance.
    -- :h MiniBracketed.yank()
    local put_keys = { 'p', 'P' }
    for _, lhs in ipairs(put_keys) do
      local rhs = 'v:lua.MiniBracketed.register_put_region("' .. lhs .. '")'
      vim.keymap.set({ 'n', 'x' }, lhs, rhs, { expr = true })
    end
  end,
}
