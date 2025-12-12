return {
	"akinsho/toggleterm.nvim",
	version = "*",
	-- The 'opts' function will be called by lazy.nvim to generate the options table.
	-- This allows us to conditionally add callbacks based on whether the minimap plugin is available.
	opts = function()
		-- Use pcall to gracefully handle cases where the minimap plugin might be disabled or not loaded.
		local ok, minimap = pcall(require, "custom.plugins.local.minimap")
		local minimap_is_available = ok

		local options = {
			-- You can add your toggleterm options here. For example:
			-- open_mapping = [[<c-\>]],
			-- direction = 'float',
		}

		-- If the minimap plugin is available, add the hooks to hide/show it.
		if minimap_is_available then
			options.on_open = function(term)
				-- If the user has the minimap enabled, close it when toggleterm opens.
				if minimap.is_user_enabled() then
					minimap.close()
				end
			end
			options.on_close = function(term)
				-- If the user has the minimap enabled, re-open it when toggleterm closes.
				if minimap.is_user_enabled() then
					minimap.open()
				end
			end
		end

		return options
	end,
	-- The config function receives the generated 'opts' table and runs setup.
	config = function(_, opts)
		require("toggleterm").setup(opts)
	end,
}
