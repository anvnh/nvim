local opt = vim.opt
local g = vim.g
g.have_nerd_font = true
opt.number = true
-- Set laststatus=3
opt.laststatus = 3

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m]"]])
vim.cmd([[let &t_Ce = "\e[4:0m]"]])

-- Set up conceallevel to 1 or 2 in order to make obsidian nvim work
-- vim.opt.conceallevel = 1
opt.conceallevel = 1
opt.foldmethod = "marker"

g.editorconfig = true

opt.exrc = true
opt.secure = true
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.number = true
opt.relativenumber = true
opt.autoindent = true
opt.smartindent = true
opt.cursorline = true
opt.wrap = false
opt.fillchars = { eob = " " }
opt.ignorecase = true
opt.smartcase = true
opt.ruler = false
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 400
-- opt.undofile = true
opt.whichwrap:append("<>[]hl")
opt.scrolloff = 8
opt.mouse = "a"
-- opt.mouse = ''
opt.showmode = false
-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
      opt.clipboard = "unnamedplus"
end)
-- Enable break indent
opt.breakindent = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true
-- Keep signcolumn on by default
opt.signcolumn = "yes"
-- Decrease update time
opt.updatetime = 250
-- Decrease mapped sequence wait time
opt.timeoutlen = 300
-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true
-- Sets how neovim will display certain whitespace characters in the editor.
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- Preview substitutions live, as you type!
opt.inccommand = "split"
-- Show which line your cursor is on
opt.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 20
