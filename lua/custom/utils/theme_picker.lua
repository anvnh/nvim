local M = {}

local uv = vim.uv or vim.loop

-- State file path for persisting selected theme
local function state_file()
      local dir = vim.fn.stdpath("data") .. "/theme"
      -- Ensure directory exists
      vim.fn.mkdir(dir, "p")
      return dir .. "/selected_theme.txt"
end

local function read_file(path)
      local fd = uv.fs_open(path, "r", 438) -- 0666
      if not fd then
            return nil
      end
      local stat = uv.fs_fstat(fd)
      if not stat then
            uv.fs_close(fd)
            return nil
      end
      local data = uv.fs_read(fd, stat.size, 0)
      uv.fs_close(fd)
      if not data or data == "" then
            return nil
      end
      -- trim whitespace/newlines
      return (data:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function write_file(path, content)
      local fd = uv.fs_open(path, "w", 420) -- 0644
      if not fd then
            return false
      end
      uv.fs_write(fd, content or "", 0)
      uv.fs_close(fd)
      return true
end

local function get_available_colorschemes()
      local ok, list = pcall(vim.fn.getcompletion, "", "color")
      if not ok or type(list) ~= "table" then
            return {}
      end
      table.sort(list)
      return list
end

local function apply_colorscheme(name)
      local ok, err = pcall(vim.cmd.colorscheme, name)
      if not ok then
            vim.notify(
                  "Không thể áp dụng theme: " .. tostring(name) .. "\n" .. tostring(err),
                  vim.log.levels.ERROR
            )
            return false
      end
      return true
end

function M.save_selected(name)
      if not name or name == "" then
            return
      end
      write_file(state_file(), name)
end

function M.load_saved()
      return read_file(state_file())
end

function M.apply_saved_or(default_theme)
      local saved = M.load_saved()
      if saved and saved ~= "" then
            if apply_colorscheme(saved) then
                  return saved, true
            end
      end
      if default_theme and default_theme ~= "" then
            if apply_colorscheme(default_theme) then
                  return default_theme, false
            end
      end
      return nil, false
end

function M.open()
      local items = get_available_colorschemes()
      if #items == 0 then
            vim.notify("Cant find any colorscheme", vim.log.levels.WARN)
            return
      end
      vim.ui.select(items, { prompt = "Select theme" }, function(choice)
            if not choice then
                  return
            end
            if apply_colorscheme(choice) then
                  M.save_selected(choice)
                  vim.notify("Selected: " .. choice)
            end
      end)
end

return M
