require 'globals'

-- Compile C/C++ with g++ and populate quickfix; if success, run the binary in a terminal split
local function compile_and_run_cpp()
	-- Save current buffer
	vim.cmd('write')

	-- Use absolute paths for robustness
	local file = vim.fn.expand('%:p')
	-- Only act on C/C++ files
	if not file:match('%.c$') and not file:match('%.cpp$') and not file:match('%.cc$') and not file:match('%.cxx$') then
		vim.notify('F1 compile-run is for C/C++ buffers', vim.log.levels.WARN)
		return
	end

		local output = vim.fn.expand('%:p:r') .. '.out'

	-- Configure local makeprg for this buffer
	-- Use strong warnings; adjust as desired
	local cmd = string.format(
		'g++ -std=c++17 -Wall -Wextra -O2 %s -o %s',
		vim.fn.shellescape(file),
		vim.fn.shellescape(output)
	)
	vim.opt_local.makeprg = cmd

	-- Run make to fill quickfix; open it on errors
	vim.cmd('silent make!')

	local qf = vim.fn.getqflist()
	if #qf > 0 then
		vim.cmd('copen')
		return
	end

	-- No compile errors: close quickfix if open and run the program in a terminal split
	pcall(vim.cmd, 'cclose')

		-- Ensure binary exists
		if vim.fn.filereadable(output) == 0 then
			vim.notify('Compiled binary not found: ' .. output, vim.log.levels.ERROR)
			vim.cmd('copen')
			return
		end
	-- Open bottom split terminal and run the binary
	vim.cmd('botright split')
	vim.cmd('resize 12')
		vim.cmd('terminal ' .. vim.fn.shellescape(output))
	vim.cmd('startinsert')
end

-- Map F1 for C/C++ buffers only
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'c', 'cpp', 'cxx', 'cc' },
	callback = function(args)
		vim.keymap.set('n', '<F1>', compile_and_run_cpp, { buffer = args.buf, noremap = true, silent = true, desc = 'Compile and run C/C++ (quickfix + terminal)' })
	end,
})