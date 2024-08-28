-- lua/plugins/copilot.lua

local prompts = {
  -- Code related prompts
  Explain = 'Please explain how the following code works.',
  Review = 'Please review the following code and provide suggestions for improvement.',
  Tests = 'Please explain how the selected code works, then generate unit tests for it.',
  Refactor = 'Please refactor the following code to improve its clarity and readability.',
  FixCode = 'Please fix the following code to make it work as intended.',
  FixError = 'Please explain the error in the following text and provide a solution.',
  BetterNamings = 'Please provide better names for the following variables and functions.',
  Documentation = 'Please provide documentation for the following code.',
  SwaggerApiDocs = 'Please provide documentation for the following API using Swagger.',
  SwaggerJsDocs = 'Please write JSDoc for the following API using Swagger.',
  -- Text related prompts
  Summarize = 'Please summarize the following text.',
  Spelling = 'Please correct any grammar and spelling errors in the following text.',
  Wording = 'Please improve the grammar and wording of the following text.',
  Concise = 'Please rewrite the following text to make it more concise.',
  Simplify = 'Please simplify the following code or text to make it easier to understand.',
  -- Neovim related prompts
}

-- Directory to save and load chats from:
local default_save_file = 'default-chat'
local last_save_file = 'last-chat'
vim.g.copilot_current_save_file = last_save_file

return {
  {
    'github/copilot.vim',
    -- event = 'VeryLazy',
    config = function()
      -- For copilot.vim
      -- enable copilot for specific filetypes
      -- TODO(kenny): not about this one.
      vim.g.copilot_filetypes = {
        ['TelescopePrompt'] = false,
      }

      -- Set to true to assume that copilot is already mapped
      vim.g.copilot_assume_mapped = true
      -- Set workspace folders
      -- NOTE: update as needed - consider narrowing to current project
      -- directory automatically.
      vim.g.copilot_workspace_folders = '~/projects'

      -- Setup keymaps
      local keymap = vim.keymap.set

      -- Set <C-y> to accept copilot suggestion
      vim.g.copilot_no_tab_map = false
      -- keymap('i', '<C-a>', 'copilot#Accept("<CR>")', { expr = true, silent = true, desc = 'Copilot: Accept suggestion' })
      -- keymap('i', '<C-a>', 'silent copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false, desc = 'Copilot: Accept suggestion' })
      keymap('i', '<C-a>', 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false, desc = 'Copilot: Accept suggestion' })

      -- Set <C-i> to accept line
      keymap('i', '<C-i>', '<Plug>(copilot-accept-line)', { silent = true, desc = 'Copilot: Accept line' })

      -- Set <C-j> to next suggestion, <C-k> to previous suggestion, <C-l> to suggest
      keymap('i', '<C-j>', '<Plug>(copilot-next)', { silent = true, desc = 'Copilot: Next suggestion' })
      keymap('i', '<C-k>', '<Plug>(copilot-previous)', { silent = true, desc = 'Copilot: Previous suggestion' })
      keymap('i', '<C-l>', '<Plug>(copilot-suggest)', { silent = true, desc = 'Copilot: Suggest' })

      -- Set <C-d> to dismiss suggestion
      keymap('i', '<C-d>', '<Plug>(copilot-dismiss)', { silent = true, desc = 'Copilot: Dismiss suggestion' })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'github/copilot.vim' }, -- for the Copilot plugin
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
      { 'nvim-telescope/telescope.nvim' }, -- Telescope for help actions, prompt, and save file picker.
    },
    opts = {
      question_header = '## User ',
      answer_header = '## Copilot ',
      error_header = '## Error ',
      separator = ' ', -- Separator to use in chat
      history_path = vim.g.copilot_history_dir,
      prompts = prompts,
      auto_follow_cursor = true, -- Don't follow the cursor after getting response
      show_help = false, -- Show help in virtual text, set to true if that's 1st time using Copilot Chat
      context = 'buffers', -- Use buffers for context
      mappings = {
        -- Use tab for completion
        -- complete = {
        --   detail = 'Use @<Tab> or /<Tab> for options.',
        --   insert = '<Tab>',
        -- },
        -- Close the chat
        close = {
          normal = 'q',
          insert = '<C-c>',
        },
        -- Reset the chat buffer
        reset = {
          normal = '<C-l>',
          insert = '<C-l>',
        },
        -- Submit the prompt to Copilot
        submit_prompt = {
          normal = '<CR>',
          insert = '<C-CR>',
        },
        -- Accept the diff
        accept_diff = {
          normal = '<C-y>',
          insert = '<C-y>',
        },
        -- Yank the diff in the response to register
        yank_diff = {
          normal = 'gmy',
        },
        -- Show the diff
        show_diff = {
          normal = 'gmd',
        },
        -- Show the prompt
        show_system_prompt = {
          normal = 'gmp',
        },
        -- Show the user selection
        show_user_selection = {
          normal = 'gms',
        },
      },
    },
    config = function(_, opts)
      local chat = require 'CopilotChat'
      local select = require 'CopilotChat.select'
      -- Use unnamed register for the selection
      opts.selection = select.unnamed

      -- Override the git prompts message
      opts.prompts.Commit = {
        prompt = 'Write commit message for the change with commitizen convention',
        selection = select.gitdiff,
      }
      opts.prompts.CommitStaged = {
        prompt = 'Write commit message for the change with commitizen convention',
        selection = function(source)
          return select.gitdiff(source, true)
        end,
      }

      chat.setup(opts)

      vim.api.nvim_create_user_command('CopilotChatVisual', function(args)
        chat.ask(args.args, { selection = select.visual })
      end, { nargs = '*', range = true })

      -- Inline chat with Copilot
      vim.api.nvim_create_user_command('CopilotChatInline', function(args)
        chat.ask(args.args, {
          selection = select.visual,
          window = {
            layout = 'float',
            relative = 'cursor',
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = '*', range = true })
      -- Inline chat with copilot with prompt
      vim.api.nvim_create_user_command('CopilotChatInlineInput', function()
        local input = vim.fn.input 'Ask Copilot: '
        chat.ask(input, {
          selection = select.visual,
          window = {
            layout = 'float',
            relative = 'cursor',
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, {})

      -- Restore CopilotChatBuffer
      vim.api.nvim_create_user_command('CopilotChatBuffer', function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = '*', range = true })

      -- Custom buffer for CopilotChat
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-*',
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          -- Get current filetype and set it to markdown if the current filetype is copilot-chat
          local ft = vim.bo.filetype
          if ft == 'copilot-chat' then
            vim.bo.filetype = 'markdown'
          end
        end,
      })

      -- Add which-key mappings
      local wk = require 'which-key'
      wk.register {
        g = {
          m = {
            name = '+Copilot Chat',
            d = 'Show diff',
            p = 'System prompt',
            s = 'Show selection',
            y = 'Yank diff',
          },
        },
      }
      -- Save the chat buffer on exit
      vim.api.nvim_create_autocmd('VimLeavePre', {
        pattern = '*',
        callback = function()
          vim.cmd('CopilotChatSave ' .. last_save_file)
          -- if last_save_file ~= vim.g.copilot_current_save_file then
          --   vim.cmd('CopilotChatSave ' .. vim.g.current_save_file)
          -- end
        end,
      })
      vim.keymap.set('n', '<leader>sa', function()
        local find_files = require('telescope.builtin').find_files
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'
        -- previewer
        -- local json_previewer = require 'telescope.previewers.json_previewer'
        local chat_previewer = require 'telescope.previewers.copilot_chat_previewer'

        find_files {
          cwd = vim.g.copilot_history_dir,
          -- previewer = json_previewer,
          previewer = chat_previewer,
          attach_mappings = function(_, map)
            local action = function(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              local filepath = entry.path
              local filename = vim.fn.fnamemodify(filepath, ':t:r')
              vim.cmd('CopilotChatLoad ' .. filename)
            end

            map('i', '<CR>', action)
            map('n', '<CR>', action)

            return true
          end,
        }
      end, { desc = '[S]earch [A]I: CopilotChat History' })
    end,
    event = 'VeryLazy',
    keys = {
      -- Show help actions with telescope
      {
        '<leader>ah',
        function()
          local actions = require 'CopilotChat.actions'
          require('CopilotChat.integrations.telescope').pick(actions.help_actions())
        end,
        desc = 'CopilotChat - Help actions',
      },
      -- Show prompts actions with telescope
      {
        '<leader>ap',
        function()
          local actions = require 'CopilotChat.actions'
          require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
        end,
        desc = 'CopilotChat - Prompt actions',
      },
      {
        '<leader>ap',
        ":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>",
        mode = 'x',
        desc = 'CopilotChat - Prompt actions',
      },
      -- Code related commands
      { '<leader>ae', '<cmd>CopilotChatExplain<cr>', desc = 'CopilotChat - [A]I Explain code' },
      { '<leader>at', '<cmd>CopilotChatTests<cr>', desc = 'CopilotChat - [A]I Generate [T]ests' },
      { '<leader>ar', '<cmd>CopilotChatReview<cr>', desc = 'CopilotChat - [A]I [R]eview code' },
      { '<leader>aR', '<cmd>CopilotChatRefactor<cr>', desc = 'CopilotChat - [A]I [R]efactor code' },
      { '<leader>an', '<cmd>CopilotChatBetterNamings<cr>', desc = 'CopilotChat - [A]I Better [N]aming' },
      -- Chat with Copilot in visual mode
      {
        '<leader>av',
        '<cmd>:CopilotChatVisual<cr>',
        mode = 'x',
        desc = 'CopilotChat - [A]I Open in [v]ertical split',
      },
      {
        '<leader>ax',
        '<cmd>:CopilotChatInline<cr>',
        mode = 'x',
        desc = 'CopilotChat - [A]I [X] Inline chat',
      },
      {
        '<leader>a<CR>',
        '<cmd>:CopilotChatInlineInput<cr>',
        mode = 'x',
        desc = 'CopilotChat - [A]I Inline chat with [P]rompt',
      },
      -- Custom input for CopilotChat
      {
        '<leader>ai',
        function()
          local input = vim.fn.input 'Ask Copilot: '
          if input ~= '' then
            vim.cmd('CopilotChat ' .. input)
          end
        end,
        desc = 'CopilotChat - [A]I Ask [i]nput',
      },
      -- Generate commit message based on the git diff
      {
        '<leader>am',
        '<cmd>CopilotChatCommit<cr>',
        desc = 'CopilotChat - [A]I Generate commit [m]essage for all changes',
      },
      {
        '<leader>aM',
        '<cmd>CopilotChatCommitStaged<cr>',
        desc = 'CopilotChat - [A]I Generate commit [M]essage for staged changes',
      },
      -- Quick chat with Copilot
      {
        '<leader>aq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            vim.cmd('CopilotChatBuffer ' .. input)
          end
        end,
        desc = 'CopilotChat - [A]I [Q]uick chat',
      },
      -- Debug
      { '<leader>ad', '<cmd>CopilotChatDebugInfo<cr>', desc = 'CopilotChat - [A]I [D]ebug Info' },
      -- Fix the issue with diagnostic
      { '<leader>af', '<cmd>CopilotChatFixDiagnostic<cr>', desc = 'CopilotChat - [A]I [F]ix Diagnostic' },
      -- Clear buffer and chat history
      { '<leader>al', '<cmd>CopilotChatReset<cr>', desc = 'CopilotChat - [A]I C[l]ear buffer and chat history' },
      -- Toggle Copilot Chat Vsplit
      { '<leader>av', '<cmd>CopilotChatToggle<cr>', desc = 'CopilotChat - [A]I Toggle [V]isual' },

      -- Save/Load to/from file.
      -- NOTE: I have also added a telescope picker for these files in init.lua
      -- which will open them with the same CopilotChatLoad command.
      -- TODO: consider adding an easy timestamped file name option.
      {
        '<leader>as',
        function()
          local input = vim.fn.input 'Save CopilotChat to file: '
          -- replace spaces in the input with underscores.
          input = input:gsub(' ', '_')
          local filename = input ~= '' and input or default_save_file
          vim.g.copilot_current_save_file = filename
          vim.cmd('CopilotChatSave ' .. filename)
        end,
        desc = 'CopilotChat - [A]I Copilot Save Chat to File.',
      },
      {
        '<leader>ao',
        function()
          local input = vim.fn.input 'Load CopilotChat from file: '
          -- replace spaces in the input with underscores.
          input = input:gsub(' ', '_')
          local filename = input ~= '' and input or default_save_file
          vim.g.copilot_current_save_file = filename
          vim.cmd('CopilotChatLoad ' .. filename)
        end,
        desc = 'CopilotChat - [A]I [O]pen CopilotChat from File.',
      },
    },
  },
}
