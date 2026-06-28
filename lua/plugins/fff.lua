return {
  'dmtrKovalenko/fff.nvim',
  -- NOTE: build manually with `OPENSSL_NO_VENDOR=1 cargo build --release`
  -- build = 'cargo build --release',
  build = function()
    require('fff.download').download_binary()
  end,
  cmd = { 'FFFFind' },
  keys = {
    -- stylua: ignore start
    { 'ff', function() require('fff').find_files() end, desc = 'FFF: find files' },
    { 'fg', function() require('fff').live_grep() end, desc = 'LiFFFe grep' },
    -- stylua: ignore end
    {
      'fw',
      function()
        require('fff').live_grep_under_cursor()
      end,
      mode = { 'n', 'x' },
      desc = 'Search current word / selection',
    },
  },
  opts = {
    layout = {
      prompt_position = 'top', -- 'top' or 'bottom'
      preview_position = 'right', -- 'left', 'right', 'top', 'bottom'
      flex = { size = 110, wrap = 'bottom' },
      min_list_height = 6, --  do not display anything except the list below this threshold
    },
  },
}
