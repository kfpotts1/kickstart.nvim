local previewers = require 'telescope.previewers'
local putils = require 'telescope.previewers.utils'
local Path = require 'plenary.path'

local copilot_chat_previewer = previewers.new_buffer_previewer {
  get_buffer_by_name = function(_, entry)
    return entry.value
  end,

  define_preview = function(self, entry, _)
    if self.state.bufnr then
      vim.api.nvim_win_set_option(self.state.winid, 'wrap', true)
      local path_to_file = Path:new(getmetatable(entry).cwd .. '/' .. entry.value):absolute()

      -- Load and decode JSON content
      local json_text = table.concat(vim.fn.readfile(path_to_file), '\n')
      local success, data = pcall(vim.fn.json_decode, json_text)
      if not success then
        vim.api.nvim_err_writeln('Error decoding JSON: ' .. data)
        return
      end

      -- Convert JSON to Markdown
      local markdown_lines = {}
      for _, chat_entry in ipairs(data) do
        -- Add markdown formatted chat entries to lines
        table.insert(markdown_lines, '## ' .. chat_entry.role)
        -- Use gsub to split content into lines, avoiding newlines within single line entries
        for _, text_line in ipairs(vim.split(chat_entry.content, '\n')) do
          table.insert(markdown_lines, text_line)
        end
        table.insert(markdown_lines, '') -- Add an empty line after each content block
      end

      -- Set the buffer lines and highlight
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, markdown_lines)
      putils.highlighter(self.state.bufnr, 'markdown')
    end
  end,
}

return copilot_chat_previewer
