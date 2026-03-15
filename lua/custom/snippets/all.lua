local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function comment_prefix()
      local cs = vim.bo.commentstring
      if cs == "" then
            return "//"
      end
      return cs:match("^(.*)%%s"):gsub("%s*$", "")
end

ls.add_snippets("all", {
      s("sec", {
            f(function()
                  return comment_prefix() .. " --------------------------------"
            end, {}),
            t({ "", "" }),
            f(function()
                  return comment_prefix() .. " "
            end, {}),
            i(1, "Section"),
            t({ "", "" }),
            f(function()
                  return comment_prefix() .. " --------------------------------"
            end, {}),
      }),
})
