return {
  "anvnh/minimap.vim",
  build = "cargo install --locked code-minimap",
  config = function()
    vim.g.minimap_width = 10
    vim.g.minimap_auto_start = 0
    vim.g.minimap_auto_start_win_enter = 0
    vim.g.minimap_git_colors = 1
    vim.g.minimap_highlight_range = 1
    vim.g.minimap_highlight_search = 1
    vim.g.minimap_base_highlight = "Normal"
    vim.g.minimap_cursor_color = "Cursor"
    vim.g.minimap_search_color = "Search"
    vim.g.minimap_range_color = "IncSearch"
    vim.g.minimap_git_add_color = "DiffAdd"
    vim.g.minimap_git_delete_color = "DiffDelete"
    vim.g.minimap_git_change_color = "DiffChange"
    vim.g.minimap_block_buftype = { "nofile", "nowrite", "quickfix", "terminal", "help" }
    vim.g.minimap_block_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" }
    vim.g.minimap_close_buftype = { "nofile", "nowrite", "quickfix", "terminal", "help" }
    vim.g.minimap_close_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" }
    vim.g.minimap_highlight_range = 1
    vim.g.minimap_highlight_search = 1
    vim.g.minimap_syntax = 1
    vim.g.minimap_base_highlight = "Normal"
    vim.g.minimap_cursor_color = "Cursor"
    vim.g.minimap_search_color = "Search"
    vim.g.minimap_range_color = "IncSearch"
    vim.g.minimap_git_add_color = "DiffAdd"
    vim.g.minimap_git_delete_color = "DiffDelete"
    vim.g.minimap_git_change_color = "DiffChange"
    vim.g.minimap_block_buftype = { "nofile", "nowrite", "quickfix", "terminal", "help" }
    vim.g.minimap_block_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" }
    vim.g.minimap_close_buftype = { "nofile", "nowrite", "quickfix", "terminal", "help" }
    vim.g.minimap_close_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" }
  end,
}
