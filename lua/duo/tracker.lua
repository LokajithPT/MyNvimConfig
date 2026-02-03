-- lua/duo/tracker.lua
local state = require("duo.state")

local M = {}

local function get_last_change(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

function M.setup()
  local group = vim.api.nvim_create_augroup("DuoTracker", { clear = true })

  -- typing
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      state.add_typed(buf, get_last_change(buf))
    end,
  })

  -- paste
  vim.api.nvim_create_autocmd("TextChangedP", {
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      state.add_pasted(buf, get_last_change(buf))
    end,
  })
end

return M

