return {
  -- Lazy
  {
    'jackMort/ChatGPT.nvim',
    event = 'VeryLazy',
    config = function()
      local api_key_cmd = os.getenv 'OPENAI_API_READ_CMD'
      require('chatgpt').setup {
        openai_params = {
          -- model = 'o1-mini',
          model = 'gpt-4o-mini',
          -- model = 'gpt-4o',
          -- model = 'o1-preview',
        },
        api_key_cmd = api_key_cmd,
      }

      -- Additional keybindings
      local wk = require 'which-key'
      wk.add {
        { '<leader>g', group = 'Chat[G]PT' },
        { '<leader>gg', '<cmd>ChatGPT<CR>', desc = 'Chat [G]PT', mode = { 'n', 'v' } },
        { '<leader>gcc', '<cmd>ChatGPTCompleteCode<CR>', desc = '[C]omplete [C]ode', mode = { 'n', 'v' } },
        { '<leader>gaa', '<cmd>ChatGPTActAs<CR>', desc = '[A]ct [A]s', mode = { 'n', 'v' } },
        { '<leader>ge', '<cmd>ChatGPTEditWithInstruction<CR>', desc = '[E]dit with instruction', mode = { 'n', 'v' } },
        -- { '<leader>gg', '<cmd>ChatGPTRun grammar_correction<CR>', desc = '[G]rammar Correction', mode = { 'n', 'v' } },
        { '<leader>gt', '<cmd>ChatGPTRun translate<CR>', desc = '[T]ranslate', mode = { 'n', 'v' } },
        { '<leader>gk', '<cmd>ChatGPTRun keywords<CR>', desc = '[K]eywords', mode = { 'n', 'v' } },
        { '<leader>gd', '<cmd>ChatGPTRun docstring<CR>', desc = '[D]ocstring', mode = { 'n', 'v' } },
        { '<leader>gat', '<cmd>ChatGPTRun add_tests<CR>', desc = '[A]dd [T]ests', mode = { 'n', 'v' } },
        { '<leader>go', '<cmd>ChatGPTRun optimize_code<CR>', desc = '[O]ptimize Code', mode = { 'n', 'v' } },
        { '<leader>gs', '<cmd>ChatGPTRun summarize<CR>', desc = '[S]ummarize', mode = { 'n', 'v' } },
        { '<leader>gf', '<cmd>ChatGPTRun fix_bugs<CR>', desc = '[F]ix Bugs', mode = { 'n', 'v' } },
        { '<leader>gx', '<cmd>ChatGPTRun explain_code<CR>', desc = 'E[x]plain Code', mode = { 'n', 'v' } },
        { '<leader>gre', '<cmd>ChatGPTRun roxygen_edit<CR>', desc = '[R]oxygen [E]dit', mode = { 'n', 'v' } },
        { '<leader>gl', '<cmd>ChatGPTRun code_readability_analysis<CR>', desc = 'Code Readability Ana[l]ysis', mode = { 'n', 'v' } },
      }
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'folke/trouble.nvim',
      'nvim-telescope/telescope.nvim',
    },
  },
}
