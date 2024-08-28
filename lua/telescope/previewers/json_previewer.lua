local previewers = require 'telescope.previewers'
local putils = require 'telescope.previewers.utils'
local Job = require 'plenary.job'

local json_previewer = previewers.new_buffer_previewer {
  get_buffer_by_name = function(_, entry)
    return entry.value
  end,

  define_preview = function(self, entry, _)
    if self.state.bufnr then
      vim.api.nvim_win_set_option(self.state.winid, 'wrap', true)
      local path_to_file = getmetatable(entry).cwd .. '/' .. entry.value

      -- Create a new Job that uses `jq` to format the JSON content
      Job:new({
        command = 'jq',
        args = { '.', path_to_file }, -- 'jq .' means to just pretty-print the input JSON.
        on_exit = vim.schedule_wrap(function(j, return_val)
          if return_val == 0 then
            local lines = j:result()
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            putils.highlighter(self.state.bufnr, 'json')
          else
            local err = j:stderr_result()
            vim.api.nvim_err_writeln(table.concat(err, '\n'))
          end
        end),
      }):start()
    end
  end,
}

return json_previewer
