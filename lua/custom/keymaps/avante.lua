require 'globals'

-- Avante keymaps
api_map('n', '<leader>aa', '<cmd>Avante<CR>', create_desc('[A]vante [A]ssistant'))
api_map('n', '<leader>ac', '<cmd>AvanteChat<CR>', create_desc('[A]vante [C]hat'))
api_map('n', '<leader>ae', '<cmd>AvanteEdit<CR>', create_desc('[A]vante [E]dit'))
api_map('n', '<leader>ag', '<cmd>AvanteGenerate<CR>', create_desc('[A]vante [G]enerate'))
api_map('n', '<leader>ar', '<cmd>AvanteReview<CR>', create_desc('[A]vante [R]eview'))
api_map('n', '<leader>at', '<cmd>AvanteTest<CR>', create_desc('[A]vante [T]est'))
api_map('n', '<leader>ap', '<cmd>AvantePrompt<CR>', create_desc('[A]vante [P]rompt'))

-- Visual mode mappings
api_map('v', '<leader>ae', '<cmd>AvanteEdit<CR>', create_desc('[A]vante [E]dit selection'))
api_map('v', '<leader>ag', '<cmd>AvanteGenerate<CR>', create_desc('[A]vante [G]enerate from selection'))
api_map('v', '<leader>ar', '<cmd>AvanteReview<CR>', create_desc('[A]vante [R]eview selection'))





