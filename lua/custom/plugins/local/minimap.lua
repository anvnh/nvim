local M = {}

-- Create a namespace for managing the viewport highlight
local ns_id = vim.api.nvim_create_namespace("MinimapViewport")
-- Create a namespace for managing diagnostic highlights
local diag_ns_id = vim.api.nvim_create_namespace("MinimapDiagnostics")
local syntax_ns_id = vim.api.nvim_create_namespace("MinimapSyntax")

-- State
local state = {
      win = nil,
      buf = nil,
      parent_win = nil,
      global_augroup = nil, -- Tracks WinEnter/BufEnter
      local_augroup = nil, -- Tracks TextChanged/Scroll for current buffer
      is_open = false, -- Tracks whether the user wants the minimap to be open
}

-- Configuration
local config = {} -- Will be populated by M.setup()

local defaults = {
      width = 12, -- Fixed width in characters
      zindex = 10,
      -- Bitmasks for Braille dots (Standard Braille ordering)
      masks = {
            { 0x1, 0x8 }, -- Line 1
            { 0x2, 0x10 }, -- Line 2
            { 0x4, 0x20 }, -- Line 3
            { 0x40, 0x80 }, -- Line 4
      },
      -- File types to ignore
      ignore_filetypes = { "toggleterm", "oil" },
      viewport_highlight = { bg = "#3b4252" },
}

-- Check if a character exists at specific column index in a line
local function has_char(line, col_idx)
      if not line then
            return false
      end
      local char = line:sub(col_idx, col_idx)
      return char ~= nil and char ~= " " and char ~= "" and char ~= "	"
end

-- Generate a single Braille character from a 2x4 chunk of text
local function encode_chunk(lines, start_line, col_chunk_idx)
      local code = 0x2800 -- Base offset for Braille patterns

      local text_col_1 = (col_chunk_idx - 1) * 2 + 1
      local text_col_2 = text_col_1 + 1

      for row = 1, 4 do
            local line = lines[start_line + row - 1]

            -- Check both columns for this braille block
            if has_char(line, text_col_1) then
                  code = code + config.masks[row][1]
            end

            if has_char(line, text_col_2) then
                  code = code + config.masks[row][2]
            end
      end

      return vim.fn.nr2char(code)
end

-- Apply diagnostic highlights to the minimap
local function update_diagnostics()
      if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
            return
      end
      if not state.parent_win or not vim.api.nvim_win_is_valid(state.parent_win) then
            return
      end

      local parent_buf = vim.api.nvim_win_get_buf(state.parent_win)
      vim.api.nvim_buf_clear_namespace(state.buf, diag_ns_id, 0, -1)

      local diags = vim.diagnostic.get(parent_buf)
      if not diags or #diags == 0 then
            return
      end

      -- Collect the highest severity diagnostic for each minimap line
      local lines_to_highlight = {}
      for _, diag in ipairs(diags) do
            local map_line = math.floor(diag.lnum / 4)
            local current_severity = lines_to_highlight[map_line] or 5 -- Use a number > any severity
            if diag.severity < current_severity then
                  lines_to_highlight[map_line] = diag.severity
            end
      end

      -- Map severity levels to highlight groups
      local severity_hl_map = {
            [vim.diagnostic.severity.ERROR] = "MinimapDiagnosticError",
            [vim.diagnostic.severity.WARN] = "MinimapDiagnosticWarn",
            [vim.diagnostic.severity.INFO] = "MinimapDiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "MinimapDiagnosticHint",
      }

      -- Apply the highlights
      for line, severity in pairs(lines_to_highlight) do
            local hl_group = severity_hl_map[severity]
            if hl_group then
                  vim.api.nvim_buf_add_highlight(state.buf, diag_ns_id, hl_group, line, 0, -1)
            end
      end
end

-- Refresh the minimap buffer
local function update_minimap()
      if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
            return
      end
      if not state.parent_win or not vim.api.nvim_win_is_valid(state.parent_win) then
            return
      end

      local parent_buf = vim.api.nvim_win_get_buf(state.parent_win)
      local lines = vim.api.nvim_buf_get_lines(parent_buf, 0, -1, false)

      -- Get tab width for accurate indentation rendering
      local tab_width = vim.api.nvim_get_option_value("tabstop", { buf = parent_buf }) or 4
      local tab_rep = string.rep(" ", tab_width)

      local output = {}

      -- Process 4 lines at a time
      for i = 1, #lines, 4 do
            -- Create a temporary expanded chunk to handle tabs
            local chunk_lines = {}
            for row = 0, 3 do
                  local l = lines[i + row] or ""
                  -- Replace tabs with spaces so indentation structure is preserved
                  l = l:gsub("	", tab_rep)
                  table.insert(chunk_lines, l)
            end

            local braille_line = ""
            for j = 1, config.width do
                  braille_line = braille_line .. encode_chunk(chunk_lines, 1, j)
            end
            table.insert(output, braille_line)
      end

      vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, output)
      update_diagnostics() -- Update diagnostic highlights
end

-- Sync Scrolling and Viewport Highlight
local function sync_scroll()
      if not state.win or not vim.api.nvim_win_is_valid(state.win) then
            return
      end
      if not state.parent_win or not vim.api.nvim_win_is_valid(state.parent_win) then
            return
      end

      local current_line = vim.api.nvim_win_get_cursor(state.parent_win)[1]

      -- 1. Sync Center Position
      local minimap_line = math.floor(current_line / 4) + 1
      local total_lines = vim.api.nvim_buf_line_count(state.buf)
      if minimap_line > total_lines then
            minimap_line = total_lines
      end

      vim.api.nvim_win_set_cursor(state.win, { minimap_line, 0 })
      vim.api.nvim_win_call(state.win, function()
            vim.cmd("normal! zz")
      end)

      -- 2. Draw Viewport Highlight (The "White Block")
      -- Get top and bottom visible lines of parent window
      local start_line = vim.api.nvim_win_call(state.parent_win, function()
            return vim.fn.line("w0")
      end)
      local end_line = vim.api.nvim_win_call(state.parent_win, function()
            return vim.fn.line("w$")
      end)

      -- Convert to minimap coordinates (0-indexed)
      local map_start = math.floor((start_line - 1) / 4)
      local map_end = math.floor((end_line - 1) / 4) + 1

      -- Apply highlight
      vim.api.nvim_buf_clear_namespace(state.buf, ns_id, 0, -1)
      vim.api.nvim_buf_set_extmark(state.buf, ns_id, map_start, 0, {
            end_row = map_end,
            hl_group = "MinimapViewport",
            hl_eol = true,
            priority = 100,
      })
end

-- Function to check if the buffer should be ignored
local function is_ignored_buffer(buf)
      local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
      for _, ft in ipairs(config.ignore_filetypes) do
            if filetype == ft then
                  return true
            end
      end
      return false
end

function M.open()
      -- If the window is already open, or the buffer is ignored, do nothing
      if (state.win and vim.api.nvim_win_is_valid(state.win)) or is_ignored_buffer(vim.api.nvim_get_current_buf()) then
            return
      end

      -- 2. SETUP: Create Window
      state.parent_win = vim.api.nvim_get_current_win()
      state.buf = vim.api.nvim_create_buf(false, true)

      -- Calculate height avoiding statusline and cmdline
      local statusline_height = (vim.o.laststatus > 0) and 1 or 0
      local height = vim.o.lines - vim.o.cmdheight - statusline_height

      local win_opts = {
            relative = "editor",
            width = config.width,
            height = height,
            col = vim.o.columns - config.width,
            row = 0,
            style = "minimal",
            focusable = false,
            border = "none",
            zindex = config.zindex,
      }

      state.win = vim.api.nvim_open_win(state.buf, false, win_opts)

      -- Visual tweaks
      vim.api.nvim_set_option_value("winblend", 0, { win = state.win })
      vim.api.nvim_set_option_value("number", false, { win = state.win })
      vim.api.nvim_set_option_value("relativenumber", false, { win = state.win })
      vim.api.nvim_set_option_value("cursorline", false, { win = state.win })

      -- 3. SETUP: Global Listeners
      state.global_augroup = vim.api.nvim_create_augroup("MinimapGlobal", { clear = true })

      -- Listener for focus changes
      vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
            group = state.global_augroup,
            callback = M.refresh_context,
      })
      -- Listener for editor resizing
      vim.api.nvim_create_autocmd("VimResized", {
            group = state.global_augroup,
            callback = function()
                  if state.win and vim.api.nvim_win_is_valid(state.win) then
                        local new_statusline_height = (vim.o.laststatus > 0) and 1 or 0
                        local new_height = vim.o.lines - vim.o.cmdheight - new_statusline_height
                        vim.api.nvim_win_set_config(state.win, {
                              relative = "editor",
                              width = config.width,
                              height = new_height,
                              col = vim.o.columns - config.width,
                              row = 0,
                              zindex = config.zindex,
                              border = "none",
                        })
                  end
            end,
      })

      -- 4. INITIALIZE: Bind to current window
      M.refresh_context()
end

function M.close()
      if state.win and vim.api.nvim_win_is_valid(state.win) then
            vim.api.nvim_win_close(state.win, true)
            state.win = nil
            if state.global_augroup then
                  vim.api.nvim_del_augroup_by_id(state.global_augroup)
            end
            if state.local_augroup then
                  vim.api.nvim_del_augroup_by_id(state.local_augroup)
            end
            state.global_augroup = nil
            state.local_augroup = nil
      end
end

-- Function called when focus changes to a new window/buffer
function M.refresh_context()
      -- Ignore if we entered the minimap window itself
      local cur_win = vim.api.nvim_get_current_win()
      if cur_win == state.win then
            return
      end

      state.parent_win = cur_win
      local parent_buf = vim.api.nvim_win_get_buf(state.parent_win)

      -- If the buffer is ignored, close the minimap and return
      if is_ignored_buffer(parent_buf) then
            if state.win and vim.api.nvim_win_is_valid(state.win) then
                  vim.api.nvim_win_close(state.win, true)
                  state.win = nil
            end
            return
      end

      -- If the buffer is not ignored and the user wants the minimap open, open it
      if state.is_open and (not state.win or not vim.api.nvim_win_is_valid(state.win)) then
            M.open()
      end

      -- Re-create local listeners for the new buffer/window
      if state.local_augroup then
            vim.api.nvim_del_augroup_by_id(state.local_augroup)
      end
      state.local_augroup = vim.api.nvim_create_augroup("MinimapLocal", { clear = true })

      -- Listener: Update content when text changes
      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
            group = state.local_augroup,
            buffer = parent_buf,
            callback = update_minimap,
      })

      -- Listener: Update highlights when diagnostics change
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
            group = state.local_augroup,
            buffer = parent_buf,
            callback = update_diagnostics, -- Only need to update highlights
      })

      -- Listener: Sync scroll when cursor moves or window scrolls
      vim.api.nvim_create_autocmd("CursorMoved", {
            group = state.local_augroup,
            buffer = parent_buf,
            callback = sync_scroll,
      })

      -- WinScrolled uses window ID pattern
      vim.api.nvim_create_autocmd("WinScrolled", {
            group = state.local_augroup,
            pattern = tostring(state.parent_win),
            callback = sync_scroll,
      })

      -- Immediate update for the new file
      update_minimap()
      sync_scroll()
end

function M.toggle()
      state.is_open = not state.is_open
      if state.is_open then
            M.open()
      else
            M.close()
      end
end

function M.setup(opts)
      -- Merge user options with defaults
      config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

      vim.api.nvim_create_user_command("Minimap", M.toggle, {})

      -- Define Highlight Group for Viewport
      vim.api.nvim_set_hl(0, "MinimapViewport", config.viewport_highlight)

      -- Define Highlight Groups for Diagnostics, linking them to existing theme highlights
      vim.api.nvim_set_hl(0, "MinimapDiagnosticError", { link = "DiagnosticError", default = true })
      vim.api.nvim_set_hl(0, "MinimapDiagnosticWarn", { link = "DiagnosticWarn", default = true })
      vim.api.nvim_set_hl(0, "MinimapDiagnosticInfo", { link = "DiagnosticInfo", default = true })
      vim.api.nvim_set_hl(0, "MinimapDiagnosticHint", { link = "DiagnosticHint", default = true })
end
return M
