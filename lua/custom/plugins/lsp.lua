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
        local util = require("lspconfig.util")

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
                map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
                map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
                map("gD", vim.lsp.buf.declaration, "Goto Declaration")

                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
        pcall(require, "lspconfig.server_configurations.nixd")
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
            gdscript = {
                capabilities = capabilities,
                cmd = { "ncat", "127.0.0.1", "6005" },
            },
            -- kotlin_language_server = { capabilities = capabilities },
            lua_ls = {
                capabilities = capabilities,
                cmd = {
                    vim.fn.exepath("lua-language-server") ~= "" and vim.fn.exepath("lua-language-server")
                        or "lua-language-server",
                },
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
                cmd = {
                    vim.fn.exepath("pyright-langserver") ~= "" and vim.fn.exepath("pyright-langserver")
                        or "pyright-langserver",
                    "--stdio",
                },
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
            nixd = {
                capabilities = capabilities,
                cmd = { vim.fn.exepath("nixd") ~= "" and vim.fn.exepath("nixd") or "nixd" },
            },
            jdtls = {
                capabilities = capabilities,
                cmd = {
                    vim.fn.exepath("jdtls") ~= "" and vim.fn.exepath("jdtls") or "jdtls",
                },
            },
            rust_analyzer = {
                capabilities = capabilities,
                cmd = {
                    vim.fn.exepath("rust-analyzer") ~= "" and vim.fn.exepath("rust-analyzer") or "rust-analyzer",
                },
                single_file_support = true,
                root_dir = function(fname)
                    return util.root_pattern("Cargo.toml", "rust-project.json")(fname)
                        or util.root_pattern(".git")(fname)
                        or vim.fs.dirname(fname)
                end,
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                        },
                        procMacro = {
                            enable = true,
                        },
                    },
                },
            },
            qmlls = {
                capabilities = capabilities,
                cmd = { "qmlls", "-E" },
                filetypes = { "qml", "qmljs" },
                root_dir = function(fname)
                    return util.root_pattern("flake.nix", ".git", "qmldir")(fname)
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

        local function has_cmd(opts)
            local cmd = opts.cmd
            if type(cmd) ~= "table" or type(cmd[1]) ~= "string" then
                return true
            end

            local bin = cmd[1]
            if bin:find("/") then
                return vim.fn.executable(bin) == 1
            end

            return vim.fn.executable(bin) == 1
        end

        for name, opts in pairs(servers) do
            if not vim.lsp.config[name] then
                vim.notify(("LSP server '%s' is not registered (nvim-lspconfig)"):format(name), vim.log.levels.WARN)
            elseif not has_cmd(opts) then
                vim.schedule(function()
                    vim.notify(("Skipping LSP server '%s': executable not found on PATH"):format(name), vim.log.levels.INFO)
                end)
            else
                vim.lsp.config(name, opts)
                vim.lsp.enable(name)
            end
        end
    end,
}
