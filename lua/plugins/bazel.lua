return {
  { 'bazelbuild/vim-bazel', dependencies = { 'google/vim-maktaba' } },
  {
    'alexander-born/bazel.nvim',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter' },
    },
    config = function()
      -- Map the vim functions to keyboard shortcuts
      vim.keymap.set('n', '<leader>bd', '<cmd>lua vim.fn.GoToBazelDefinition()<CR>', { desc = 'Goto [B]azel [D]efinition' })
      vim.keymap.set('n', '<leader>bt', '<cmd>lua vim.fn.GoToBazelTarget()<CR>', { desc = 'Goto [B]azel [T]arget' })

      -- Use the lua functions in your configuration
      local bazel = require 'bazel'

      -- Run the last bazel command when leader br is pressed
      vim.keymap.set('n', '<leader>br', '<cmd>lua bazel.run_last()<CR>', { desc = '[B]azel [R]un' })

      -- Add more configurations as needed...
    end,
  },
}
