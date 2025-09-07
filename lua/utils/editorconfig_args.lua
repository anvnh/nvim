-- utils/editorconfig_args.lua
local M = {}

function M.tab_width(buf)
  local bo = vim.bo[buf]
  return (bo.shiftwidth > 0 and bo.shiftwidth) or bo.tabstop or 4
end

function M.use_tabs(buf)
  return not vim.bo[buf].expandtab
end

function M.text_width(buf)
  local tw = vim.bo[buf].textwidth or 0
  return tw > 0 and tw or nil
end

return M
