-- Configure diagnostics to be less intrusive
vim.diagnostic.config({
    virtual_text = false, -- Disable inline diagnostic text
    signs = true, -- Keep diagnostic signs in gutter
    underline = true, -- Keep underline for errors
    update_in_insert = false, -- Don't update diagnostics while typing
    severity_sort = true, -- Sort diagnostics by severity
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

-- NOTE: Make :W = :w
vim.api.nvim_create_user_command("W", "w", {})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- NOTE: Highlight when yanking (copying) text
vim.api.nvim_set_hl(0, "YankHighlight", {
    bg = "#2370eb",
    ctermbg = 24,
})
-- Create autocommand to highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstarthighlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank({
            higroup = "YankHighlight",
            timeout = 200,
        })
    end,
})

require("options")
require("globals")
require("autocmds")
require("mappings")
require("custom.commands")

-- require 'custom.keymaps.init'
require("lazy").setup({
    import = "custom.plugins",
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🗝",
            plugin = "🔌",
            runtime = "💻",
            require = "🌙",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤 ",
        },
    },
})

-- Apply saved theme (fallback to catppuccin)
pcall(function()
    local theme = require("custom.utils.theme_picker")
    theme.apply_saved_or("catppuccin")
end)

-- dofile(vim.g.base46_cache .. 'defaults')
-- dofile(vim.g.base46_cache .. 'statusline')
-- dofile(vim.g.base46_cache .. 'syntax')
-- dofile(vim.g.base46_cache .. 'treesitter')
do
    local cache = vim.g.base46_cache
    if type(cache) == "string" and vim.fn.isdirectory(cache) == 1 then
        for _, f in ipairs(vim.fn.readdir(cache)) do
            local join = (vim.fs and vim.fs.joinpath)
                or function(a, b)
                    if a:sub(-1) == "/" then
                        return a .. b
                    else
                        return a .. "/" .. b
                    end
                end
            local fp = join(cache, f)
            if vim.fn.filereadable(fp) == 1 then
                pcall(dofile, fp)
            end
        end
    end
end

-- NOTE: LOCAL PLUGINS
require("custom.plugins.local.url_opener").setup()
require("custom.plugins.local.minimap").setup()
