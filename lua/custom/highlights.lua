local function apply_cpp_highlights()
    local theme = vim.g.colors_name or ""
    local color

    if theme:match("^tokyonight") then
        color = "#BB9AF7"
    elseif theme:match("^catppuccin") then
        color = "#CBA6F7"
    else
        return
    end

    for _, group in ipairs({
        "@keyword.directive.define.cpp",
        "@keyword.directive.cpp",
    }) do
        vim.api.nvim_set_hl(0, group, { fg = color })
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("CustomCppHighlights", { clear = true }),
    callback = apply_cpp_highlights,
})

apply_cpp_highlights()
