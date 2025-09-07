local M = {}
M.map = vim.keymap.set
M.api_map = vim.api.nvim_set_keymap
M.opts = { noremap = true, silent = true }
function M.create_desc(desc)
	return vim.tbl_extend("force", M.opts, { desc = desc })
end

_G.map = M.map
_G.api_map = M.api_map
_G.opts = M.opts
_G.create_desc = M.create_desc
return M
