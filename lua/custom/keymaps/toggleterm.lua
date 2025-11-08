require("globals")

---{{{ Old
-- api_map('n', '<leader>f', '<Cmd>lua require("nvterm.terminal").toggle("float")<CR>', {noremap = true, silent = true})
-- api_map('n', '<leader>h', '<Cmd>lua require("nvterm.terminal").toggle("horizontal")<CR>', create_desc 'Toggle [H]orizontal terminal')
-- api_map('n', '<leader>v', '<Cmd>lua require("nvterm.terminal").toggle("vertical")<CR>', create_desc 'Toggle [V]ertical terminal')
---}}}

---{{{ New
api_map("n", "<leader>h", "<Cmd> ToggleTerm direction=horizontal<CR>", create_desc("Toggle [H]orizontal terminal"))
api_map("n", "<leader>v", "<Cmd> ToggleTerm direction=vertical<CR>", create_desc("Toggle [V]ertical terminal"))
-- api_map('n', '<leader>f', '<Cmd> ToggleTerm direction=float<CR>', create_desc 'Toggle [F]loat terminal')
---}}}
