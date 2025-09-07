-- Theme persistence
local theme_loader = require('custom.theme-loader')

-- Theme toggle keymaps
local function toggle_theme_mode()
  local current_bg = vim.o.background
  local new_bg = current_bg == "dark" and "light" or "dark"
  
  -- Update background
  vim.o.background = new_bg
  
  -- Reload gruvbox with new background
  if vim.g.colors_name == "gruvbox" then
    vim.cmd("colorscheme gruvbox")
    -- Save the configuration
    theme_loader.save_theme("gruvbox", new_bg)
  end
  
  -- Show notification
  vim.notify("Switched to " .. new_bg .. " mode", vim.log.levels.INFO)
end

local function show_catppuccin_picker()
  local catppuccin_flavors = {
    "catppuccin-latte",
    "catppuccin-frappe", 
    "catppuccin-macchiato",
    "catppuccin-mocha",
  }
  
  vim.ui.select(catppuccin_flavors, {
    prompt = "Select Catppuccin Flavor:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      vim.cmd("colorscheme " .. choice)
      -- Save the configuration
      local bg = choice == "catppuccin-latte" and "light" or "dark"
      theme_loader.save_theme(choice, bg)
      vim.notify("Switched to " .. choice, vim.log.levels.INFO)
    end
  end)
end

local function show_theme_picker()
  local themes = {
    "catppuccin-frappe",
    "gruvbox",
  }
  
  local mode_options = {
    "Dark Mode",
    "Light Mode",
  }
  
  -- Show theme picker
  vim.ui.select(themes, {
    prompt = "Select Theme:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      vim.cmd("colorscheme " .. choice)
      -- Save the configuration
      local bg = choice == "catppuccin-frappe" and "dark" or "dark"
      theme_loader.save_theme(choice, bg)
      vim.notify("Switched to " .. choice, vim.log.levels.INFO)
      
      -- If gruvbox is selected, show mode picker
      if choice == "gruvbox" then
        vim.ui.select(mode_options, {
          prompt = "Select Gruvbox Mode:",
          format_item = function(item)
            return item
          end,
        }, function(mode_choice)
          if mode_choice then
            local bg = mode_choice == "Dark Mode" and "dark" or "light"
            vim.o.background = bg
            vim.cmd("colorscheme gruvbox")
            -- Save the configuration
            theme_loader.save_theme("gruvbox", bg)
            vim.notify("Switched to " .. choice .. " (" .. mode_choice .. ")", vim.log.levels.INFO)
          end
        end)
      end
    end
  end)
end

-- Keymaps
vim.keymap.set("n", "<leader>tt", show_theme_picker, { desc = "[T]oggle [T]heme" })
vim.keymap.set("n", "<leader>tm", toggle_theme_mode, { desc = "[T]oggle [M]ode (Dark/Light)" })
vim.keymap.set("n", "<leader>tc", show_catppuccin_picker, { desc = "[T]oggle [C]atppuccin Flavor" })
