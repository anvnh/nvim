require("globals")

---{{{ Clear hightlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
---}}}

--{{{ Move focus window
map("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })
---}}}

--{{{ Increment/decrement
map("n", "+", "<C-a>", opts)
map("n", "-", "<C-x>", opts)
---}}}

--{{{ Split window
map("n", "ss", ":split<CR>", opts)
map("n", "sv", ":vsplit<CR>", opts)
---}}}

--{{{Ctrl - C acts as escape
map("i", "<C-c>", "<ESC>", { noremap = true, silent = true })
---}}}

--{{{ Exit terminal mode
api_map("t", "<C-x>", "<C-\\><C-N>", create_desc("Exit terminal mode"))
--}}}

--{{{ Window size
api_map("n", "<C-S-A-Down>", "<Cmd>resize +3<CR>", opts)
api_map("n", "<C-S-A-Up>", "<Cmd>resize -3<CR>", opts)
api_map("n", "<C-S-A-Left>", "<Cmd>vertical resize +5<CR>", opts)
api_map("n", "<C-S-A-Right>", "<Cmd>vertical resize -5<CR>", opts)
--}}}

--{{{ Goto definition
api_map(
      "n",
      "gpd",
      "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
      create_desc("Preview [D]efinition")
)
--}}}

--{{{ Comment
api_map("n", "<leader>/", '<cmd>lua require("Comment.api").toggle.linewise.current()<CR>', create_desc("Comment line"))
api_map(
      "v",
      "<leader>/",
      '<ESC><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
      create_desc("Comment selection")
)
--}}}

--{{{ Line number
api_map("n", "<leader>nu", "<cmd>set nu!<CR>", create_desc("Toggle line number"))
api_map("n", "<leader>rnu", "<cmd>set rnu!<CR>", create_desc("Toggle relative line number"))
--}}}

--{{{ LSP Code action
map("n", "<leader>ca", function()
      vim.lsp.buf.code_action()
end, { desc = "Code action" })
--}}}

--{{{ Diagnostics
-- Show diagnostic under cursor
map("n", "<leader>d", function()
      vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Show diagnostic under cursor" })

-- Show all diagnostics in current buffer
map("n", "<leader>dd", function()
      vim.diagnostic.setloclist()
end, { desc = "Show all diagnostics in buffer" })

-- Navigate diagnostics
map("n", "[d", function()
      vim.diagnostic.goto_prev()
end, { desc = "Go to previous diagnostic" })

map("n", "]d", function()
      vim.diagnostic.goto_next()
end, { desc = "Go to next diagnostic" })

-- Toggle diagnostic virtual text
map("n", "<leader>dt", function()
      local current = vim.diagnostic.config().virtual_text
      vim.diagnostic.config({ virtual_text = not current })
end, { desc = "Toggle diagnostic virtual text" })
--}}}

--{{{ Theme picker
map("n", "<leader>tt", function()
      require("custom.utils.theme_picker").open()
end, { desc = "Select theme" })
--}}}
