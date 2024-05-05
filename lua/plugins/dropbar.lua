return {
  'Bekaboo/dropbar.nvim',
  enabled = false,
  config = function()
    local menu_utils = require('dropbar.utils.menu')

    vim.keymap.set('n', '<leader>o', require('dropbar.api').pick, { desc = 'Winbar pick' })

    -- Closes all the windows in the current dropbar.
    local function close()
      local menu = menu_utils.get_current()
      while menu and menu.prev_menu do
        menu = menu.prev_menu
      end
      if menu then
        menu:close()
      end
    end

    require('dropbar').setup({
      general = {
        update_interval = 100,
      },
      menu = {
        keymaps = {
          -- Navigate back to the parent menu.
          ['h'] = '<C-w>c',
          -- Expands the entry if possible.
          ['l'] = function()
            local menu = menu_utils.get_current()
            if not menu then
              return
            end
            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
            if component then
              menu:click_on(component, nil, 1, 'l')
            end
          end,
          -- "Jump and close".
          ['o'] = function()
            local menu = menu_utils.get_current()
            if not menu then
              return
            end
            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            local entry = menu.entries[cursor[1]]
            local component = entry:first_clickable(entry.padding.left + entry.components[1]:bytewidth())
            if component then
              menu:click_on(component, nil, 1, 'l')
            end
          end,
          -- Close the dropbar entirely with <esc> and q.
          ['q'] = close,
          ['<esc>'] = close,
        },
      },
      bar = {
        sources = function(buf, _)
          local sources = require('dropbar.sources')
          local utils = require('dropbar.utils')
          local filename = {
            get_symbols = function(buff, win, cursor)
              local path = sources.path.get_symbols(buff, win, cursor)
              return { path[#path] }
            end,
          }
          if vim.bo[buf].ft == 'markdown' then
            return {
              filename,
              utils.source.fallback({
                sources.treesitter,
                sources.markdown,
                sources.lsp,
              }),
            }
          end
          return {
            filename,
            utils.source.fallback({
              sources.lsp,
              sources.treesitter,
            }),
          }
        end,
      },
    })
  end,
}
