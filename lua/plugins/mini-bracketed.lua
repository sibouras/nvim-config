return {
  'echasnovski/mini.bracketed',
  event = 'VeryLazy',
  opts = {
    file = { suffix = 'r', options = { wrap = false } },
    buffer = { suffix = 'e', options = { wrap = false } },
    oldfile = { suffix = 'o', options = { wrap = false } },
    conflict = { suffix = 'x', options = {} },
    location = { suffix = 'l', options = {} },
    yank = { suffix = 'y', options = {} },
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
}
