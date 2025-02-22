vim.filetype.add({
  extension = {
    conf = 'conf',
    ejs = 'ejs',
    json = 'jsonc',
    ahk2 = 'autohotkey',
  },
  filename = {
    ['.eslintrc'] = 'jsonc',
    ['.prettierrc'] = 'jsonc',
    ['.babelrc'] = 'jsonc',
    ['.stylelintrc'] = 'jsonc',
  },
  pattern = {
    ['.*config/git/config'] = 'gitconfig',
    ['.env.*'] = 'sh',
  },
})
