local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("user-config", { clear = true })

autocmd("User", {
    group = group,
    pattern = "UndotreeHide",
    callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local bufname = vim.api.nvim_buf_get_name(buf)
            if bufname == "[No Name]" then
                vim.cmd("bdelete! " .. buf)
            end
        end
    end,
})

autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function()
        vim.b.autoformat = false
    end,
})

autocmd("BufReadPost", {
    group = group,
    pattern = "*",
    callback = function()
        local line = vim.fn.line("'\"")
        if
            line > 1
            and line <= vim.fn.line("$")
            and vim.bo.filetype ~= "commit"
            and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
        then
            vim.cmd('normal! g`"')
        end
    end,
})
