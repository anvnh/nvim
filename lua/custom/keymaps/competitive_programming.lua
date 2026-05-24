require("globals")

local run_terminal
local close_on_key_ns = vim.api.nvim_create_namespace("cpp_run_output_close_on_key")

local function clear_close_on_next_key()
    pcall(vim.on_key, nil, close_on_key_ns)
end

local function close_run_terminal(term)
    clear_close_on_next_key()

    if term then
        pcall(function()
            term:shutdown()
        end)
    end

    if run_terminal == term then
        run_terminal = nil
    end
end

local function close_on_next_key(term)
    clear_close_on_next_key()

    vim.on_key(function()
        vim.schedule(function()
            if term and term.bufnr == vim.api.nvim_get_current_buf() then
                close_run_terminal(term)
            end
        end)
    end, close_on_key_ns)
end

local function map_close_key(term, modes)
    if not term.bufnr or not vim.api.nvim_buf_is_valid(term.bufnr) then
        return
    end

    vim.keymap.set(modes or "n", "Q", function()
        close_run_terminal(term)
    end, {
        buffer = term.bufnr,
        noremap = true,
        silent = true,
        desc = "Close run output",
    })
end

local function run_in_terminal(cmd)
    local ok, toggleterm_terminal = pcall(require, "toggleterm.terminal")

    if ok then
        close_run_terminal(run_terminal)

        run_terminal = toggleterm_terminal.Terminal:new({
            cmd = cmd,
            close_on_exit = false,
            direction = "float",
            hidden = true,
            float_opts = {
                border = "curved",
                height = function()
                    return math.floor(vim.o.lines * 0.85)
                end,
                width = function()
                    return math.floor(vim.o.columns * 0.9)
                end,
            },
            on_open = function(term)
                map_close_key(term)
                vim.cmd("startinsert!")
            end,
            on_exit = function(term)
                vim.schedule(function()
                    map_close_key(term, { "n", "t" })

                    if term:is_open() and vim.api.nvim_get_current_win() == term.window then
                        vim.cmd("stopinsert")
                        close_on_next_key(term)
                    end
                end)
            end,
        })

        run_terminal:open()
        return
    end

    -- Fallback for cases where toggleterm is unavailable.
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.85)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
    })

    local function close_fallback_terminal()
        clear_close_on_next_key()

        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end

        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    local function map_fallback_close_key(modes)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end

        vim.keymap.set(modes, "Q", close_fallback_terminal, {
            buffer = buf,
            noremap = true,
            silent = true,
            desc = "Close run output",
        })
    end

    map_fallback_close_key("n")

    vim.fn.termopen(cmd, {
        on_exit = function()
            vim.schedule(function()
                map_fallback_close_key({ "n", "t" })

                if vim.api.nvim_win_is_valid(win) then
                    if vim.api.nvim_get_current_win() == win then
                        vim.cmd("stopinsert")
                        clear_close_on_next_key()

                        vim.on_key(function()
                            vim.schedule(function()
                                if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_current_buf() == buf then
                                    close_fallback_terminal()
                                end
                            end)
                        end, close_on_key_ns)
                    end
                end
            end)
        end,
    })
    vim.cmd("startinsert!")
end

-- Compile C/C++ with g++ and populate quickfix; if success, run the binary in a terminal
local function compile_and_run_cpp()
    vim.cmd("write")

    local file = vim.fn.expand("%:p")
    if
        not file:match("%.c$")
        and not file:match("%.cpp$")
        and not file:match("%.cc$")
        and not file:match("%.cxx$")
    then
        vim.notify("F1 compile-run is for C/C++ buffers", vim.log.levels.WARN)
        return
    end

    local output = vim.fn.expand("%:p:r") .. ".out"
    local compile_cmd = string.format(
        "g++ -std=c++17 -Wall -Wextra -Wno-unused-variable -O2 %s -o %s",
        vim.fn.shellescape(file),
        vim.fn.shellescape(output)
    )
    vim.opt_local.makeprg = compile_cmd

    vim.cmd("silent make!")

    local qf = vim.fn.getqflist()
    if #qf > 0 then
        vim.cmd("copen")
        return
    end

    pcall(vim.cmd, "cclose")

    if vim.fn.filereadable(output) == 0 then
        vim.notify("Compiled binary not found: " .. output, vim.log.levels.ERROR)
        vim.cmd("copen")
        return
    end

    run_in_terminal(vim.fn.shellescape(output))
end

-- Map F1 for C/C++ buffers only
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "cxx", "cc" },
    callback = function(args)
        vim.keymap.set("n", "<F1>", compile_and_run_cpp, {
            buffer = args.buf,
            noremap = true,
            silent = true,
            desc = "Compile and run C/C++ (quickfix + terminal)",
        })
    end,
})
