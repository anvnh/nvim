return {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function()
        vim.keymap.set({ "n", "x", "o" }, "zj", "<Plug>(leap-forward)", { desc = "Leap forward" })
        vim.keymap.set({ "n", "x", "o" }, "zk", "<Plug>(leap-backward)", { desc = "Leap backward" })
    end,
}
