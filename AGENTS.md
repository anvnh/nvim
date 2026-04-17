# Agent Guide: Neovim Configuration

This repository contains a modular Neovim configuration written in Lua, managed by `lazy.nvim`.

## 🏗 Architecture & Organization

The configuration is split into several logical layers:

- **Core Settings**: `lua/options.lua` (Vim options), `lua/mappings.lua` (Keybinding entry point), `lua/globals.lua` (Global helper functions).
- **Plugin Management**: Managed by `lazy.nvim` in `init.lua`. Plugins are imported from `lua/custom/plugins/`.
- **Custom Logic**:
    - `lua/custom/plugins/`: Individual files for each plugin's configuration.
    - `lua/custom/keymaps/`: Plugin-specific keybindings, separated from the plugin setup.
    - `lua/custom/utils/`: Utility functions used across the config.
    - `lua/custom/snippets/`: Custom Luasnip snippets.
    - `lua/custom/plugins/local/`: Local plugins developed specifically for this setup.

## 🛠 Coding Standards & Conventions

### Lua Patterns
- **Indentation**: 4 spaces.
- **Naming**: Use `snake_case` for local variables and functions.
- **Organization**: Use `{{{` and `}}}` fold markers to group related blocks of code.
- **Globals**: Use the global `map` function defined in `lua/globals.lua` for all keybindings.

### Keybinding Convention
- **Leader Key**: Space (` `).
- **Plugin Bindings**: Generally organized in `lua/custom/keymaps/`.
- **Descriptions**: Always include a `desc` field in the `opts` table for `which-key` integration.

### Plugin Management
- **Adding Plugins**: Create a new file in `lua/custom/plugins/<plugin_name>.lua`. Return a table or list of tables as per `lazy.nvim` spec.
- **Configuring Plugins**: Use the `config` or `opts` key in the lazy spec.
- **Keymaps**: If a plugin has multiple keymaps, create a corresponding file in `lua/custom/keymaps/` and require it in `lua/mappings.lua`.

## 🤖 Instructions for Agents

### When adding a new feature or plugin:
1. **Research existing plugins**: Check `lua/custom/plugins/` to avoid duplicates.
2. **Create the config**: Place plugin configuration in `lua/custom/plugins/<name>.lua`.
3. **Setup Keymaps**: If the plugin requires user-facing keymaps, add them to a new file in `lua/custom/keymaps/` and link it in `lua/mappings.lua`.
4. **Follow style**: Use 4-space indentation and include descriptions for all mappings.
5. **Verify**: Ensure the modular structure is maintained; do not dump logic into `init.lua`.

### When modifying existing behavior:
- Check `lua/options.lua` for global settings.
- Check `lua/custom/keymaps/generals.lua` for core navigation and editing maps.
- Check `lua/globals.lua` for helper functions that might simplify your task.

## 📦 Key Components
- **LSP**: Configured in `lua/custom/plugins/lsp.lua`.
- **Telescope**: Configured in `lua/custom/plugins/telescope.lua`.
- **Treesitter**: Configured in `lua/custom/plugins/treesitter.lua`.
- **Completion**: Configured in `lua/custom/plugins/completion.lua` (using `nvim-cmp`).
