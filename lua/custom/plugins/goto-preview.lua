return {
    "rmagatti/goto-preview",
    dependencies = "rmagatti/logger.nvim",
    config = function()
        require("goto-preview").setup({})
    end,
}
