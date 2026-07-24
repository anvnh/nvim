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

        local servers = {
            clangd = {
                capabilities = (function()
                    local cap = vim.deepcopy(capabilities)
                    cap.offsetEncoding = { "utf-16" }
                    return cap
                end)(),
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--all-scopes-completion",
                    "--header-insertion=iwyu",
                },
            },
            ts_ls = {
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
            lua_ls = {
                settings = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        diagnostics = { globals = { "vim" } },
                        completion = { callSnippet = "Replace" },
                    },
                },
            },
            pyright = {
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoImportCompletions = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "openFilesOnly",
                        },
                    },
                },
            },
            jdtls = {},
            rust_analyzer = {
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
                cmd = { "qmlls", "-E" },
                filetypes = { "qml", "qmljs" },
                root_dir = function(fname)
                    return util.root_pattern("flake.nix", ".git", "qmldir")(fname)
                        or vim.loop.cwd()
                end,
            },
            bashls = {
                filetypes = { "sh", "bash" },
            },
        }

        require("mason").setup()

        local ensure_installed = vim.tbl_keys(servers)
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
            automatic_installation = true,
        })

        for name, opts in pairs(servers) do
            opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})
            vim.lsp.config(name, opts)
            vim.lsp.enable(name)
        end
    end,
}
