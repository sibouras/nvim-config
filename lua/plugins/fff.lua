return {
  'dmtrKovalenko/fff.nvim',
  -- bad commit: https://github.com/dmtrKovalenko/fff.nvim/pull/175
  commit = '3c76ba523f12356955f3207d61cdd7a7dee686a6',
  -- NOTE: build manually with `OPENSSL_NO_VENDOR=1 cargo build --release`
  -- build = 'cargo build --release',
  build = function()
    -- this will download prebuild binary or try to use existing rustup toolchain to build from source
    -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
    require('fff.download').download_or_build_binary()
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
