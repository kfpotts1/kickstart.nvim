--[[
-- Harpoon configuration
-- roughtly based on https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/harpoon.lua
--]]
local harpoon_leader = 'f'
return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
    keys = {
      {
        '<leader>' .. harpoon_leader .. harpoon_leader,
        function()
          local harpoon = require 'harpoon'
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'Harpoon toggle menu',
      },
      {
        '<leader>' .. harpoon_leader .. 'a',
        function()
          local harpoon = require 'harpoon'
          harpoon:list():add()
          vim.notify('Added to Harpoon.', vim.log.levels.INFO, { title = 'Harpoon' })
        end,
        desc = 'Harpoon Add File',
      },
      {
        '<leader>' .. harpoon_leader .. 'j',
        function()
          local harpoon = require 'harpoon'
          harpoon:list():next()
        end,
        desc = 'Harpoon Next',
      },
      {
        '<leader>' .. harpoon_leader .. 'k',
        function()
          local harpoon = require 'harpoon'
          harpoon:list():prev()
        end,
        desc = 'Harpoon Prev',
      },
    },
    opts = {
      settings = {
        save_on_toggle = false,
        sync_on_ui_close = false,
        -- NOTE: not working - think I need to instal lazyvim.util?
        -- key = function()
        --   -- Use the current working directory as the key
        --   local cwd = require('lazyvim.util').root.cwd()
        --   return cwd
        -- end,
      },
    },
    config = function(_, options)
      harpoon = require 'harpoon'

      ---@diagnostic disable-next-line: missing-parameter
      harpoon.setup(options)
      local quick_keys = {
        'y',
        'u',
        'i',
        'o',
        'p',
      }
      for i = 1, 5 do
        local key = quick_keys[i]
        local select_func = function()
          require('harpoon'):list():select(i)
        end
        -- NOTE: kenny: not sure which one is better yet. Trying both to expirment.
        vim.keymap.set('n', '<leader>' .. harpoon_leader .. key, select_func, {
          noremap = true,
          silent = true,
          desc = 'Harpoon select ' .. i,
        })
        vim.keymap.set('n', '<leader>' .. i, select_func, {
          noremap = true,
          silent = true,
          desc = 'Harpoon select ' .. i,
        })
      end

      -- Telescope integration
      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        if #file_paths == 0 then
          vim.notify('No mark found', vim.log.levels.INFO, { title = 'Harpoon' })
          return
        end

        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set('n', '<leader>sm', function()
        toggle_telescope(harpoon:list())
      end, { desc = 'Open harpoon window' })
      --
    end,
  },
}
