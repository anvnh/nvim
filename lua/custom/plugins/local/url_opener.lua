local M = {}

-- Configurable options
M.options = {
      keymap = "gx", -- Set to false to disable default mapping
      debug = false,
}

-- Helper: Log to console if debug is enabled
local function log(msg)
      if M.options.debug then
            print("[URL-Opener] " .. msg)
      end
end

-- Helper: Detect OS and open command (Fallback for < NVIM 0.10)
local function open_uri_legacy(uri)
      local cmd
      if vim.fn.has("mac") == 1 then
            cmd = { "open", uri }
      elseif vim.fn.has("win32") == 1 or vim.fn.has("wsl") == 1 then
            cmd = { "explorer.exe", uri }
      elseif vim.fn.has("unix") == 1 then
            cmd = { "xdg-open", uri }
      else
            print("Error: Unsupported OS for opening links.")
            return
      end

      local ret = vim.fn.jobstart(cmd, { detach = true })
      if ret <= 0 then
            print("Error: Failed to open URI: " .. uri)
      end
end

-- Main function to open the URI
function M.open_link()
      -- regex to match a generic URL
      local uri_pattern = "https?://[%w-_%.%?%/:%+=&%%]+"

      -- Get the current line and cursor column
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-based index

      -- Try to find a URL at the specific cursor position
      local s, e, found_url

      -- Iterate over all matches in the line to find which one includes the cursor
      local init = 1
      while true do
            local start_idx, end_idx = string.find(line, uri_pattern, init)
            if not start_idx then
                  break
            end

            if col >= start_idx and col <= end_idx then
                  found_url = string.sub(line, start_idx, end_idx)
                  s = start_idx
                  e = end_idx
                  break
            end
            init = end_idx + 1
      end

      -- Fallback: If no strict regex match, try expand('<cfile>') which is standard vim behavior
      if not found_url then
            local cfile = vim.fn.expand("<cfile>")
            if cfile:match("https?://") then
                  found_url = cfile
            end
      end

      if not found_url then
            print("No URL found under cursor.")
            return
      end

      log("Opening: " .. found_url)

      -- Use vim.ui.open if available (Neovim 0.10+), otherwise fallback
      if vim.ui.open then
            vim.ui.open(found_url)
      else
            open_uri_legacy(found_url)
      end
end

-- Setup function for the user config
function M.setup(opts)
      M.options = vim.tbl_deep_extend("force", M.options, opts or {})

      -- Create user command
      vim.api.nvim_create_user_command("OpenLink", M.open_link, {})

      -- Set keymap if configured
      if M.options.keymap then
            vim.keymap.set("n", M.options.keymap, M.open_link, { desc = "Open URL under cursor" })
      end
end

return M

