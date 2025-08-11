return {
  'dmtrKovalenko/fff.nvim',
  -- NOTE: build manually with `OPENSSL_NO_VENDOR=1 cargo build --release`
  -- build = 'cargo build --release',
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
  opts = {},
}
