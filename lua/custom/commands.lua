vim.api.nvim_create_user_command("ConfigValidate", function()
    vim.cmd("checkhealth")
end, {
    desc = "Run Neovim health checks for this config",
})
