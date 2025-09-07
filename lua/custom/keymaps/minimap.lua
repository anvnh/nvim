local M = {}

M.setup = function()
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- Toggle minimap
  keymap("n", "<leader>mm", ":MinimapToggle<CR>", opts)
  keymap("n", "<leader>mM", ":MinimapClose<CR>", opts)

  -- Minimap navigation
  keymap("n", "<leader>m<Up>", ":MinimapScrollUp<CR>", opts)
  keymap("n", "<leader>m<Down>", ":MinimapScrollDown<CR>", opts)
  keymap("n", "<leader>m<Left>", ":MinimapScrollLeft<CR>", opts)
  keymap("n", "<leader>m<Right>", ":MinimapScrollRight<CR>", opts)

  -- Minimap search
  keymap("n", "<leader>ms", ":MinimapSearch<CR>", opts)
  keymap("n", "<leader>mS", ":MinimapSearchClear<CR>", opts)

  -- Minimap update
  keymap("n", "<leader>mu", ":MinimapRefresh<CR>", opts)

  -- Minimap resize
  keymap("n", "<leader>m+", ":MinimapResize +1<CR>", opts)
  keymap("n", "<leader>m-", ":MinimapResize -1<CR>", opts)
  keymap("n", "<leader>m=", ":MinimapResize 0<CR>", opts)
end

return M
