return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local treesitter = require("nvim-treesitter")

        treesitter.setup()

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "bash",
                "c",
                "cpp",
                "diff",
                "html",
                "lua",
                "markdown",
                "query",
                "vim",
                "help",
                "tex",
            },
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)

                if vim.bo[args.buf].filetype ~= "ruby" then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
