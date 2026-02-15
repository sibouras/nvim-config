return {
  'dmtrKovalenko/fff.nvim',
  -- NOTE: build manually with `OPENSSL_NO_VENDOR=1 cargo build --release`
  -- build = 'cargo build --release',
  -- https://github.com/dmtrKovalenko/fff.nvim/issues/228
  commit = 'd7bc72786d4362ca70aa05d397f8d08bbaf39604',
  build = function()
    require('fff.download').download_binary()
  end,
  cmd = { 'FFFFind' },
  keys = {
    {
      'ff',
      function()
        require('fff').find_files()
      end,
      desc = 'FFF: find files',
    },
  },
  opts = {
    layout = {
      prompt_position = 'top', -- 'top' or 'bottom'
      preview_position = 'right', -- 'left', 'right', 'top', 'bottom'
    },
  },
}
