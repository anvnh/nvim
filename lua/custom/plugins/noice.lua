-- NOTE: Neovim >= 0.9.0

return {
	"folke/noice.nvim",
	event = "VeryLazy",
	-- opts = function(_, opts)
	--   table.insert(opts.routes, {
	--     filter = {
	--       event = 'notify',
	--       find = 'No information available',
	--     },
	--     opts = {
	--       skip = true,
	--     },
	--   })
	-- end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		-- 'rcarriga/nvim-notify',
	},
	config = function()
		-- require('notify').setup {
		--   background_colour = 'FloatShadow',
		--   fps = 120,
		--   icons = {
		--     DEBUG = '',
		--     ERROR = '',
		--     INFO = '',
		--     TRACE = '✎',
		--     WARN = '',
		--   },
		--   level = 2,
		--   minimum_width = 50,
		--   render = 'minimal',
		--   stages = 'slide',
		--   time_formats = {
		--     notification = '%T',
		--     notification_history = '%FT%T',
		--   },
		--   timeout = 1000,
		--   top_down = true,
		-- }
		require("noice").setup({
			routes = {
				{
					-- Find another text other the "no information available" in the notify event
					filter = {
						event = "notify",
						find = "No signature help available",
					},
					opts = { skip = true },
				},
			},
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = false, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = true, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
			messages = {
				enabled = true, -- enables the Noice messages UI
				view = "notify", -- default view for messages
				view_error = "notify", -- view for errors
				view_warn = "notify", -- view for warnings
				view_history = "messages", -- view for :messages
				view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
			},
			-- CLEAN CMDLINE POP UP
			views = {
				cmdline_popup = {
					position = {
						-- row = '30%',
						-- col = '50%',
						row = "9%",
						col = "50%",
						-- row = '58%',
						-- col = '50%',
					},
					size = {
						width = 60,
						height = "auto",
					},
				},
				popupmenu = {
					relative = "editor",
					position = {
						row = 8,
						col = "50%",
					},
					size = {
						width = 60,
						height = 10,
					},
					border = {
						style = "single",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
					},
				},
			},
		})
	end,
}
