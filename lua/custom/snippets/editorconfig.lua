local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {
      ls.add_snippets("editorconfig", {
            s({ trig = "editorconfig" }, {
                  t({
                        "# EditorConfig is awesome: https://EditorConfig.org",
                        "root = true",
                        "",
                        "[*.{js,jsx,ts,tsx}]",
                        "indent_style = space",
                        "indent_size = 2",
                        "insert_final_newline = true",
                        "charset = utf-8",
                        "trim_trailing_whitespace = true",
                        "end_of_line = lf",
                        "",
                        "[*.{json,html,css,md}]",
                        "indent_style = space",
                        "indent_size = 2",
                        "insert_final_newline = true",
                        "charset = utf-8",
                        "trim_trailing_whitespace = true",
                        "end_of_line = lf",
                        "",
                        "[*.{yml,yaml}]",
                        "indent_style = space",
                        "indent_size = 2",
                        "insert_final_newline = true",
                        "charset = utf-8",
                        "trim_trailing_whitespace = true",
                        "end_of_line = lf",
                        "",
                        "[*.{py}]",
                        "indent_style = space",
                        "indent_size = 4",
                        "insert_final_newline = true",
                        "charset = utf-8",
                        "trim_trailing_whitespace = true",
                        "end_of_line = lf",
                  }),
            }),
      }),
}
