return {
  'iofq/dart.nvim',
  opts = function()
    local dart = require('dart')

    return {
      -- List of characters to use to mark 'pinned' buffers
      -- The characters will be chosen for new pins in order
      marklist = { 'a', 's', 'd', 'f' },

      -- List of characters to use to mark recent buffers, which are displayed first (left) in the tabline
      -- Buffers that are 'marked' are not included in this list
      -- The length of this list determines how many recent buffers are tracked
      buflist = { 'w', 'e', 'r' },

      -- Default mappings
      mappings = {
        mark = '<leader>im',
        jump = '<leader>i',
        pick = '<leader>ii',
        next = '<C-n>',
        prev = '<C-p>',
      },
      tabline = {
        -- Reverse tabline order, so marklist is to the left, and buflist to the right:
        order = function()
          local order = {}
          for i, key in ipairs(vim.list_extend(vim.deepcopy(dart.config.marklist), dart.config.buflist)) do
            order[key] = i
          end
          return order
        end,
      },
    }
  end,
}
