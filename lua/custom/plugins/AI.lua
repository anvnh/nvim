return {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
  },
  {
    'copilotc-nvim/copilotchat.nvim',
    cmd = {
      'CopilotChat',
      'CopilotChatOpen',
      'CopilotChatClose',
      'CopilotChatToggle',
      'CopilotChatModels',
    },
    dependencies = {
      { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
  },
  -- {
  --   'Exafunction/codeium.vim',
  --   event = 'BufEnter',
  -- },
}
