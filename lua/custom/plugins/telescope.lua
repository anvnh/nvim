return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      {
        "nvim-tree/nvim-web-devicons",
        enabled = vim.g.have_nerd_font,
      },
    },
    config = function()
      require("globals")
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require("telescope.builtin")

      map("n", "<leader>ff", function()
        builtin.find_files({
          find_command = { "fd", "--type", "f", "--hidden", "--no-ignore-vcs", "--exclude", ".git" },
        })
      end, { desc = "[F]ind [F]iles" })
      map("n", "<leader>ro", builtin.oldfiles, { desc = "[R]ecently [O]pened files" })
      map("n", "<leader>gf", builtin.live_grep, { desc = "[G]rep [F]iles" })
      map("n", "<leader>lb", builtin.buffers, { desc = "[L]ist [B]uffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "[H]elp [T]ags" })

      map("n", "<leader>sc", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "Fuzzily search in current buffer" })

      map("n", "<leader>s/", function()
        builtin.live_grep({ prompt_title = "Live Grep in Open Files" })
      end, { desc = "[S]earch [/] in Open Files" })

      map("n", "<leader>sf", function()
        builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
      end, { desc = "[S]earch [/] in Open Files" })

      map("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })
    end,
  },
}
