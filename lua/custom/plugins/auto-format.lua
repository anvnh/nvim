return {
  "stevearc/conform.nvim",
  config = function()
    local conform = require("conform")
    local ec = require("utils.editorconfig_args")

    conform.setup({
      format_on_save = { lsp_format = "fallback", timeout_ms = 2000 },
      notify_on_error = true,

      -- apply to all filetypes; you can prune this list to what you use
      formatters_by_ft = {
        lua = { "stylua" },
        cpp = { "clang_format" },
        c = { "clang_format" },
        objc = { "clang_format" },
        objcxx = { "clang_format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        python = { "black" },          -- note: tabs unsupported by black
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        rust = { "rustfmt" },
        go = { "gofmt" },              -- gofmt ignores width; see limits below
        ["_"] = { "trim_whitespace" },
      },

      -- universal overrides: convert buffer opts (set by .editorconfig) → CLI flags
      formatters = {
        prettier = {
          -- Prettier already reads .editorconfig; still harden with flags per-buffer.
          prepend_args = function(_, ctx)
            local use_tabs = ec.use_tabs(ctx.buf)
            local width = tostring(ec.tab_width(ctx.buf))
            return { "--use-tabs=" .. tostring(use_tabs), "--tab-width", width }
          end,
        },

        clang_format = {
          -- clang-format DOES NOT read .editorconfig; force via -style
          prepend_args = function(_, ctx)
            local width = ec.tab_width(ctx.buf)
            local tabs = ec.use_tabs(ctx.buf)
            local tw = ec.text_width(ctx.buf)
            local style = string.format(
              "{BasedOnStyle: LLVM, IndentWidth: %d, TabWidth: %d, UseTab: %s%s}",
              width,
              width,
              tabs and "Always" or "Never",
              tw and (", ColumnLimit: " .. tw) or ""
            )
            return { "-style", style }
          end,
        },

        shfmt = {
          prepend_args = function(_, ctx)
            local args = { "-i", tostring(ec.tab_width(ctx.buf)) }
            if ec.use_tabs(ctx.buf) then table.insert(args, "-tabs") end
            return args
          end,
        },

        stylua = {
          -- Stylua ignores .editorconfig; force indent/width
          prepend_args = function(_, ctx)
            local args = {
              "--indent-width",
              tostring(ec.tab_width(ctx.buf)),
              "--indent-type",
              ec.use_tabs(ctx.buf) and "Tabs" or "Spaces",
            }
            local tw = ec.text_width(ctx.buf)
            if tw then vim.list_extend(args, { "--column-width", tostring(tw) }) end
            return args
          end,
        },

        black = {
          -- Black ignores tabs and always uses 4 spaces; only max line length can be driven.
          prepend_args = function(_, ctx)
            local tw = ec.text_width(ctx.buf)
            return tw and { "-l", tostring(tw) } or {}
          end,
        },

        rustfmt = {
          -- rustfmt reads rustfmt.toml; inject .editorconfig values via --config
          -- Works on stable: --config key=val[,key=val...]
          prepend_args = function(_, ctx)
            local parts = {
              "hard_tabs=" .. tostring(ec.use_tabs(ctx.buf)),
              "tab_spaces=" .. tostring(ec.tab_width(ctx.buf)),
            }
            local tw = ec.text_width(ctx.buf)
            if tw then table.insert(parts, "max_width=" .. tostring(tw)) end
            return { "--config", table.concat(parts, ",") }
          end,
        },

        gofmt = {
          -- gofmt doesn’t take width options; nothing to pass.
          -- Keep for completeness; Go tools use tabs by convention.
        },
      },
     })
   end,

   -- Auto-reload editorconfig when .editorconfig file is modified
   init = function()
     vim.api.nvim_create_autocmd("BufWritePost", {
       pattern = ".editorconfig",
       callback = function()
         -- chạy EditorConfig lại cho tất cả buffer đang mở
         for _, buf in ipairs(vim.api.nvim_list_bufs()) do
           if vim.api.nvim_buf_is_loaded(buf) then
             vim.api.nvim_set_current_buf(buf)
             vim.cmd("doautocmd BufReadPost")
           end
         end
       end,
     })
   end,
 }
