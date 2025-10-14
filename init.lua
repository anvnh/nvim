-- NOTE: Disable automatic diagnostic display - only show on manual trigger
-- vim.api.nvim_create_autocmd('CursorHold', {
--   callback = function()
--     vim.diagnostic.open_float(nil, { focus = false })
--   end,
-- })

vim.opt.termguicolors = true

-- Configure diagnostics to be less intrusive
vim.diagnostic.config({
      virtual_text = false, -- Disable inline diagnostic text
      signs = true, -- Keep diagnostic signs in gutter
      underline = true, -- Keep underline for errors
      update_in_insert = false, -- Don't update diagnostics while typing
      severity_sort = true, -- Sort diagnostics by severity
      float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
      },
})

local autocmd = vim.api.nvim_create_autocmd

-- NOTE: Dynamic terminal padding
autocmd("VimEnter", {
      command = ":silent !kitty @ set-spacing padding=0 margin=0",
})

autocmd("VimLeavePre", {
      command = ":silent !kitty @ set-spacing padding=20 margin=10",
})

vim.api.nvim_create_autocmd("User", {
      pattern = "UndotreeHide",
      callback = function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                  local bufname = vim.api.nvim_buf_get_name(buf)
                  if bufname == "[No Name]" then -- Buffer không có tên (No Name)
                        vim.cmd("bdelete! " .. buf)
                  end
            end
      end,
})

-- Add this to your init.lua or relevant config file
vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
            vim.b.autoformat = false -- Disable autoformatting for markdown files
      end,
})

-- NOTE: Enable godothost for coding in godot
-- local projectfile = vim.fn.getcwd() .. '/project.godot'
-- if projectfile then
--   vim.fn.serverstart './godothost'
-- end

-- NOTE: Restore cursor position when open file
autocmd("BufReadPost", {
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

-- NOTE: :W and :w are the same
vim.api.nvim_create_user_command("W", "w", {})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
      local lazyrepo = "https://github.com/folke/lazy.nvim.git"
      local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
      if vim.v.shell_error ~= 0 then
            error("Error cloning lazy.nvim:\n" .. out)
      end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- NOTE: Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`

vim.api.nvim_create_autocmd("TextYankPost", {
      desc = "Highlight when yanking (copying) text",
      group = vim.api.nvim_create_augroup("kickstarthighlight-yank", { clear = true }),
      callback = function()
            vim.highlight.on_yank({})
      end,
})

require("options")
require("mappings")
require("globals")

-- require 'custom.keymaps.init'
require("lazy").setup({
      "tpope/vim-sleuth",
      {
            "lewis6991/gitsigns.nvim",
            opts = {
                  signs = {
                        add = { text = "+" },
                        change = { text = "~" },
                        delete = { text = "_" },
                        topdelete = { text = "‾" },
                        changedelete = { text = "~" },
                  },
            },
      },
      {
            "nvim-telescope/telescope.nvim",
            event = "VimEnter",
            dependencies = {
                  "nvim-lua/plenary.nvim",
                  {
                        "nvim-telescope/telescope-fzf-native.nvim",
                        build = "make",
                        cond = function()
                              return vim.fn.executable("make") == 1
                        end,
                  },
                  { "nvim-telescope/telescope-ui-select.nvim" },
                  {
                        "nvim-tree/nvim-web-devicons",
                        enabled = vim.g.have_nerd_font,
                  },
            },
            config = function()
                  require("telescope").setup({
                        extensions = {
                              ["ui-select"] = {
                                    require("telescope.themes").get_dropdown(),
                              },
                        },
                  })

                  -- Enable Telescope extensions if they are installed
                  pcall(require("telescope").load_extension, "fzf")
                  pcall(require("telescope").load_extension, "ui-select")

                  local builtin = require("telescope.builtin")

                  vim.keymap.set(
                        "n",
                        "<leader>ff",
                        builtin.find_files,
                        { noremap = true, silent = true, desc = "[F]ind [F]iles" }
                  )
                  vim.keymap.set(
                        "n",
                        "<leader>ro",
                        builtin.oldfiles,
                        { noremap = true, silent = true, desc = "[R]ecently [O]pened files" }
                  )
                  vim.keymap.set(
                        "n",
                        "<leader>gf",
                        builtin.live_grep,
                        { noremap = true, silent = true, desc = "[G]rep [F]iles" }
                  )
                  vim.keymap.set(
                        "n",
                        "<leader>lb",
                        builtin.buffers,
                        { noremap = true, silent = true, desc = "[L]ist [B]uffers" }
                  )
                  vim.keymap.set(
                        "n",
                        "<leader>fh",
                        builtin.help_tags,
                        { noremap = true, silent = true, desc = "[H]elp [T]ags" }
                  )

                  vim.keymap.set("n", "<leader>sc", function()
                        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
                        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                              winblend = 10,
                              previewer = false,
                        }))
                  end, { desc = "Fuzzily search in current buffer" })

                  -- It's also possible to pass additional configuration options.
                  --  See `:help telescope.builtin.live_grep()` for information about particular keys
                  vim.keymap.set("n", "<leader>s/", function()
                        builtin.live_grep({
                              grep_open_files = true,
                              prompt_title = "Live Grep in Open Files",
                        })
                  end, { desc = "[S]earch [/] in Open Files" })

                  -- Shortcut for searching your Neovim configuration files
                  vim.keymap.set("n", "<leader>sn", function()
                        builtin.find_files({ cwd = vim.fn.stdpath("config") })
                  end, { desc = "[S]earch [N]eovim files" })
            end,
      },
      {
            "folke/lazydev.nvim",
            ft = "lua",
            opts = {
                  library = {
                        { path = "luvit-meta/library", words = { "vim%.uv" } },
                  },
            },
      },
      { "Bilal2453/luvit-meta", lazy = true },
      {
            "neovim/nvim-lspconfig",
            dependencies = {
                  { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
                  "williamboman/mason-lspconfig.nvim",
                  "WhoIsSethDaniel/mason-tool-installer.nvim",
                  -- `opts = {}` is the same as calling `require('fidget').setup({})`
                  { "j-hui/fidget.nvim", opts = {} },
                  "hrsh7th/cmp-nvim-lsp",
            },
            config = function()
                  vim.api.nvim_create_autocmd("LspAttach", {
                        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                        callback = function(event)
                              local map = function(keys, func, desc, mode)
                                    mode = mode or "n"
                                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                              end
                              -- Jump to the definition of the word under your cursor.
                              --  This is where a variable was first declared, or where a function is defined, etc.
                              --  To jump back, press <C-t>.
                              map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                              -- Find references for the word under your cursor.
                              map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

                              -- Jump to the implementation of the word under your cursor.
                              --  Useful when your language has ways of declaring types without an actual implementation.
                              map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                              -- Jump to the type of the word under your cursor.
                              --  Useful when you're not sure what type a variable is and you want to see
                              --  the definition of its *type*, not where it was *defined*.
                              map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

                              -- Fuzzy find all the symbols in your current document.
                              --  Symbols are things like variables, functions, types, etc.
                              map(
                                    "<leader>ds",
                                    require("telescope.builtin").lsp_document_symbols,
                                    "[D]ocument [S]ymbols"
                              )

                              -- Fuzzy find all the symbols in your current workspace.
                              --  Similar to document symbols, except searches over your entire project.
                              map(
                                    "<leader>ws",
                                    require("telescope.builtin").lsp_dynamic_workspace_symbols,
                                    "[W]orkspace [S]ymbols"
                              )

                              -- Rename the variable under your cursor.
                              --  Most Language Servers support renaming across files, etc.
                              -- map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                              -- Execute a code action, usually your cursor needs to be on top of an error
                              -- or a suggestion from your LSP for this to activate.
                              map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

                              map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                              local client = vim.lsp.get_client_by_id(event.data.client_id)
                              if
                                    client
                                    and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
                              then
                                    local highlight_augroup =
                                          vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                                          buffer = event.buf,
                                          group = highlight_augroup,
                                          callback = vim.lsp.buf.document_highlight,
                                    })

                                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                                          buffer = event.buf,
                                          group = highlight_augroup,
                                          callback = vim.lsp.buf.clear_references,
                                    })

                                    vim.api.nvim_create_autocmd("LspDetach", {
                                          group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                                          callback = function(event2)
                                                vim.lsp.buf.clear_references()
                                                vim.api.nvim_clear_autocmds({
                                                      group = "kickstart-lsp-highlight",
                                                      buffer = event2.buf,
                                                })
                                          end,
                                    })
                              end

                              if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                                    map("<leader>th", function()
                                          vim.lsp.inlay_hint.enable(
                                                not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                                          )
                                    end, "[T]oggle Inlay [H]ints")
                              end
                        end,
                  })

                  local capabilities = vim.lsp.protocol.make_client_capabilities()
                  capabilities =
                        vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

                  local servers = {
                        clangd = {
                              capabilities = vim.tbl_deep_extend("force", capabilities, { offsetEncoding = { "utf-16" } }),
                              cmd = {
                                    "clangd",
                                    "--background-index",
                                    "--clang-tidy",
                                    "--all-scopes-completion",
                                    "--header-insertion=iwyu",
                              },
                        },
                        ts_ls = {
                              capabilities = capabilities,
                              -- You can uncomment this to override the default filetypes that ts_ls will attach to
                              settings = {
                                    typescript = {
                                          inlayHints = {
                                                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
                                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                                includeInlayFunctionParameterTypeHints = true,
                                                includeInlayVariableTypeHints = true,
                                                includeInlayPropertyDeclarationTypeHints = true,
                                                includeInlayFunctionLikeReturnTypeHints = true,
                                                includeInlayEnumMemberValueHints = true,
                                          },
                                    },
                                    javascript = {
                                          inlayHints = {
                                                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
                                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                                includeInlayFunctionParameterTypeHints = true,
                                                includeInlayVariableTypeHints = true,
                                                includeInlayPropertyDeclarationTypeHints = true,
                                                includeInlayFunctionLikeReturnTypeHints = true,
                                                includeInlayEnumMemberValueHints = true,
                                          },
                                    },
                              },
                        },
                        -- lua_ls = {
                        -- 	-- cmd = { ... },
                        -- 	-- filetypes = { ... },
                        -- 	capabilities = {},
                        -- 	settings = {
                        -- 		Lua = {
                        -- 			completion = {
                        -- 				callSnippet = "Replace",
                        -- 			},
                        -- 			-- diagnostics = { disable = { 'missing-fields' } },
                        -- 		},
                        -- 	},
                        -- },
                  }
                  local package_install = vim.tbl_keys(servers or {})
                  vim.list_extend(package_install, {
                        "stylua",
                        "clangd",
                        "biome",
                        "jdtls",
                        "quick_lint_js",
                        "pyright",
                        "tailwindcss",
                        "ts_ls",
                        "ast_grep",
                        "eslint_d",
                  })

                  local mason_packages_to_install = {}
                  for _, pkg in ipairs(package_install) do
                        -- Check if the package is not already installed
                        if vim.fn.executable(pkg) == 0 then
                              table.insert(mason_packages_to_install, pkg)
                        end
                  end

                  require("mason").setup()

                  local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

                  require("lspconfig").gdscript.setup({})
                  require("lspconfig").kotlin_language_server.setup({
                        filetypes = { "kotlin", "kt", "kts" },
                        capabilities = cmp_capabilities, -- tell language server about completion capabilities
                  })
                  require("mason-tool-installer").setup({
                        ensure_installed = mason_packages_to_install,
                  })
                  require("mason-lspconfig").setup({
                        ensure_installed = {},
                        automatic_installation = true,
                        handlers = {
                              function(server_name)
                                    local server = servers[server_name] or {}
                                    -- This handles overriding only values explicitly passed
                                    -- by the server configuration above. Useful when disabling
                                    -- certain features of an LSP (for example, turning off formatting for ts_ls)
                                    server.capabilities =
                                          vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                                    require("lspconfig")[server_name].setup(server)
                              end,
                        },
                  })
            end,
      },

      { -- Autocompletion
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
            dependencies = {
                  {
                        "L3MON4D3/LuaSnip",
                        build = (function()
                              -- Build Step is needed for regex support in snippets.
                              -- This step is not supported in many windows environments.
                              -- Remove the below condition to re-enable on windows.
                              if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                                    return
                              end
                              return "make install_jsregexp"
                        end)(),
                        dependencies = {
                              -- `friendly-snippets` contains a variety of premade snippets.
                              --    See the README about individual language/framework/plugin snippets:
                              --    https://github.com/rafamadriz/friendly-snippets
                              -- {
                              --   'rafamadriz/friendly-snippets',
                              --   config = function()
                              --     require('luasnip.loaders.from_vscode').lazy_load()
                              --   end,
                              -- },
                        },
                  },
                  "saadparwaiz1/cmp_luasnip",
                  "hrsh7th/cmp-nvim-lsp",
                  "hrsh7th/cmp-path",
            },
            config = function()
                  local cmp = require("cmp")
                  local luasnip = require("luasnip")
                  luasnip.config.setup({})
                  cmp.setup({
                        snippet = {
                              expand = function(args)
                                    luasnip.lsp_expand(args.body)
                              end,
                        },
                        completion = { completeopt = "menu,menuone,noinsert" },

                        mapping = cmp.mapping.preset.insert({
                              -- Select the [n]ext item
                              ["<C-n>"] = cmp.mapping.select_next_item(),
                              -- Select the [p]revious item
                              ["<C-p>"] = cmp.mapping.select_prev_item(),

                              -- Scroll the documentation window [b]ack / [f]orward
                              ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                              ["<C-f>"] = cmp.mapping.scroll_docs(4),

                              -- Accept ([y]es) the completion.
                              --  This will auto-import if your LSP supports it.
                              --  This will expand snippets if the LSP sent a snippet.
                              ["<C-y>"] = cmp.mapping.confirm({ select = true }),

                              -- If you prefer more traditional completion keymaps,
                              -- you can uncomment the following lines
                              ["<CR>"] = cmp.mapping.confirm({ select = true }),
                              -- ['<Tab>'] = cmp.mapping.select_next_item(),
                              --['<S-Tab>'] = cmp.mapping.select_prev_item(),

                              ["<C-Space>"] = cmp.mapping.complete({}),

                              -- Think of <c-l> as moving to the right of your snippet expansion.
                              --  So if you have a snippet that's like:
                              --  function $name($args)
                              --    $body
                              --  end
                              --
                              -- <c-l> will move you to the right of each of the expansion locations.
                              -- <c-h> is similar, except moving you backwards.
                              ["<C-l>"] = cmp.mapping(function()
                                    if luasnip.expand_or_locally_jumpable() then
                                          luasnip.expand_or_jump()
                                    end
                              end, { "i", "s" }),
                              ["<C-h>"] = cmp.mapping(function()
                                    if luasnip.locally_jumpable(-1) then
                                          luasnip.jump(-1)
                                    end
                              end, { "i", "s" }),
                        }),
                        sources = {
                              {
                                    name = "lazydev",
                                    -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
                                    group_index = 0,
                              },
                              { name = "nvim_lsp" },
                              { name = "luasnip" },
                              { name = "path" },
                        },
                  })
            end,
      },
      {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            main = "nvim-treesitter.configs", -- Sets main module to use for opts
            -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
                          opts = {
                  ensure_installed = {
                        "bash",
                        "c",
                                          "cpp",
                        "diff",
                        "html",
                        "lua",
                        "luadoc",
                        "markdown",
                        "markdown_inline",
                        "query",
                        "vim",
                        "vimdoc",
                        "latex",
                  },
                  -- Autoinstall languages that are not installed
                  auto_install = true,
                  -- autotag = { enable = true },
                  highlight = {
                        enable = true,
                        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                        --  If you are experiencing weird indenting issues, add the language to
                        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                        additional_vim_regex_highlighting = { "ruby" },
                  },
                  indent = { enable = true, disable = { "ruby" } },
            },
      },

      {
            import = "custom.plugins",
      },
}, {
      ui = {
            -- If you are using a Nerd Font: set icons to an empty table which will use the
            -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
            icons = vim.g.have_nerd_font and {} or {
                  cmd = "⌘",
                  config = "🛠",
                  event = "📅",
                  ft = "📂",
                  init = "⚙",
                  keys = "🗝",
                  plugin = "🔌",
                  runtime = "💻",
                  require = "🌙",
                  source = "📄",
                  start = "🚀",
                  task = "📌",
                  lazy = "💤 ",
            },
      },
})

-- Load Catppuccin theme
vim.cmd.colorscheme("catppuccin")

-- dofile(vim.g.base46_cache .. 'defaults')
-- dofile(vim.g.base46_cache .. 'statusline')
-- dofile(vim.g.base46_cache .. 'syntax')
-- dofile(vim.g.base46_cache .. 'treesitter')
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
      dofile(vim.g.base46_cache .. v)
end
