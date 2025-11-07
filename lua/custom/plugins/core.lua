return {
      "tpope/vim-sleuth",
      {
            "lewis6991/gitsigns.nvim",
            opts = {
                  signs = {
                        add = { text = "+" },
                        change = { text = "~" },
                        delete = { text = "_" },
                        topdelete = { text = "‾" },
                        changedelete = { text = "~" },
                  },
            },
      },
      {
            "folke/lazydev.nvim",
            ft = "lua",
            opts = {
                  library = {
                        { path = "luvit-meta/library", words = { "vim%.uv" } },
                  },
            },
      },
      {
            "Bilal2453/luvit-meta",
            lazy = true
      },
}
