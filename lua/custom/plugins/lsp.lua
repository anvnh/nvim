return {
      "neovim/nvim-lspconfig",
      dependencies = {
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            "hrsh7th/cmp-nvim-lsp",
      },
      config = function()
            -- Keymaps on LSP attach
            vim.api.nvim_create_autocmd("LspAttach", {
                  group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                  callback = function(event)
                        local map = function(keys, func, desc, mode)
                              mode = mode or "n"
                              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                        end

                        map("gd", require("telescope.builtin").lsp_definitions, "Goto Definition")
                        map("gr", require("telescope.builtin").lsp_references, "Goto References")
                        map("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
                        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type Definition")
                        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
                        map(
                              "<leader>ws",
                              require("telescope.builtin").lsp_dynamic_workspace_symbols,
                              "Workspace Symbols"
                        )
                        map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
                        map("gD", vim.lsp.buf.declaration, "Goto Declaration")

                        local client = vim.lsp.get_client_by_id(event.data.client_id)
                        if
                              client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
                        then
                              local hl = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                              vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                                    buffer = event.buf,
                                    group = hl,
                                    callback = vim.lsp.buf.document_highlight,
                              })
                              vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                                    buffer = event.buf,
                                    group = hl,
                                    callback = vim.lsp.buf.clear_references,
                              })
                              vim.api.nvim_create_autocmd("LspDetach", {
                                    group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                                    callback = function(ev2)
                                          vim.lsp.buf.clear_references()
                                          vim.api.nvim_clear_autocmds({
                                                group = "kickstart-lsp-highlight",
                                                buffer = ev2.buf,
                                          })
                                    end,
                              })
                        end

                        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                              map("<leader>th", function()
                                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                              end, "Toggle Inlay Hints")
                        end
                  end,
            })

            -- Capabilities (cmp)
            local capabilities = vim.tbl_deep_extend(
                  "force",
                  vim.lsp.protocol.make_client_capabilities(),
                  require("cmp_nvim_lsp").default_capabilities()
            )

            -- Make sure to load server definitions before accessing vim.lsp.config[name]
            pcall(require, "lspconfig.server_configurations.clangd")
            pcall(require, "lspconfig.server_configurations.ts_ls")
            pcall(require, "lspconfig.server_configurations.tsserver")
            -- pcall(require, "lspconfig.server_configurations.kotlin_language_server")
            pcall(require, "lspconfig.server_configurations.gdscript")
            pcall(require, "lspconfig.server_configurations.lua_ls")
            pcall(require, "lspconfig.server_configurations.pyright")
            pcall(require, "lspconfig.server_configurations.prettierd")
            pcall(require, "lspconfig.server_configurations.jdtls")
            pcall(require, "lspconfig.server_configurations.rust_analyzer")
            pcall(require, "lspconfig.server_configurations.qmlls")

            -- Select TS server (prefer ts_ls, fallback to tsserver)
            local ts_name
            if vim.lsp.config.ts_ls then
                  ts_name = "ts_ls"
            elseif vim.lsp.config.tsserver then
                  ts_name = "tsserver"
            else
                  -- Try to load both to see which is available
                  pcall(require, "lspconfig.server_configurations.ts_ls")
                  pcall(require, "lspconfig.server_configurations.tsserver")
                  if vim.lsp.config.ts_ls then
                        ts_name = "ts_ls"
                  elseif vim.lsp.config.tsserver then
                        ts_name = "tsserver"
                  else
                        ts_name = "ts_ls" -- default to ts_ls
                  end
            end

            local servers = {
                  clangd = (function()
                        local cap = vim.deepcopy(capabilities)
                        cap.offsetEncoding = { "utf-16" }
                        return {
                              capabilities = cap,
                              cmd = {
                                    vim.fn.exepath("clangd") ~= "" and vim.fn.exepath("clangd") or "clangd",
                                    "--background-index",
                                    "--clang-tidy",
                                    "--all-scopes-completion",
                                    "--header-insertion=iwyu",
                              },
                        }
                  end)(),
                  [ts_name] = {
                        capabilities = capabilities,
                        settings = {
                              typescript = {
                                    inlayHints = {
                                          includeInlayParameterNameHints = "all",
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
                                          includeInlayParameterNameHints = "all",
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
                  gdscript = { capabilities = capabilities },
                  -- kotlin_language_server = { capabilities = capabilities },
                  lua_ls = {
                        capabilities = capabilities,
                        settings = {
                              Lua = {
                                    workspace = { checkThirdParty = false },
                                    diagnostics = { globals = { "vim" } },
                                    completion = { callSnippet = "Replace" },
                              },
                        },
                  },
                  pyright = {
                        capabilities = capabilities,
                        settings = {
                              python = {
                                    analysis = {
                                          typeCheckingMode = "basic", -- "off" | "basic" | "strict"
                                          autoImportCompletions = true,
                                          useLibraryCodeForTypes = true,
                                          diagnosticMode = "openFilesOnly",
                                    },
                              },
                        },
                  },
                  jdtls = { capabilities = capabilities },
                  rust_analyzer = { capabilities = capabilities },
                  qmlls = {
                        capabilities = capabilities,
                        cmd = { "qmlls", "-E" },
                        filetypes = { "qml", "qmljs" },
                        root_dir = function(fname)
                              return require("lspconfig.util").root_pattern("flake.nix", ".git", "qmldir")(fname)
                                    or vim.loop.cwd()
                        end,
                  },
            }

            -- NixOS: Check if binaries are on PATH
            require("mason").setup()
            require("mason-tool-installer").setup({ ensure_installed = {} })
            require("mason-lspconfig").setup({
                  ensure_installed = {},
                  automatic_installation = false,
            })

            local function warn_missing(bin)
                  if vim.fn.exepath(bin) == "" then
                        vim.schedule(function()
                              vim.notify("Binary missing on PATH: " .. bin .. " (using Nix)", vim.log.levels.WARN)
                        end)
                  end
            end
            for _, b in ipairs({
                  "clangd",
                  "typescript-language-server",
                  "pyright",
                  "tailwindcss-language-server",
                  "eslint_d",
                  -- "kotlin-language-server",
                  "stylua",
                  "biome",
                  "rust-analyzer",
            }) do
                  warn_missing(b)
            end

            -- Autostart with new API
            local group = vim.api.nvim_create_augroup("lsp-auto-start", { clear = true })

            local function ensure_loaded(name)
                  if vim.lsp.config[name] then
                        return true
                  end
                  local ok = pcall(require, "lspconfig.server_configurations." .. name)
                  return ok and vim.lsp.config[name] ~= nil
            end

            local function autostart(name, opts)
                  if not ensure_loaded(name) then
                        vim.notify(
                              ("LSP server '%s' is not registered (nvim-lspconfig)"):format(name),
                              vim.log.levels.WARN
                        )
                        return
                  end
                  local base = vim.lsp.config[name]
                  if type(base) ~= "table" then
                        vim.notify(("vim.lsp.config['%s'] is not a table"):format(name), vim.log.levels.ERROR)
                        return
                  end
                  local cfg = vim.tbl_deep_extend("force", {}, base, opts or {})
                  local fts = cfg.filetypes or {}
                  if #fts == 0 then
                        return
                  end

                  vim.api.nvim_create_autocmd("FileType", {
                        group = group,
                        pattern = fts,
                        callback = function(ev)
                              if next(vim.lsp.get_clients({ bufnr = ev.buf, name = name })) then
                                    return
                              end
                              local final = vim.tbl_deep_extend("force", {}, cfg, { bufnr = ev.buf })
                              vim.lsp.start(final)
                        end,
                  })
            end

            for name, opts in pairs(servers) do
                  autostart(name, opts)
            end
      end,
}
