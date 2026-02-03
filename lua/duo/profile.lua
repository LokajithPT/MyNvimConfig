local M = {}

local state  = require("duo.state")
local sender = require("duo.sender")

function M.open()
  local lines = {
    " Duo.nvim Profile ",
    "────────────────────",
    "",
    " Running      : " .. (state.running and "YES" or "NO"),
    " Auto Sync    : " .. (state.auto_sync and "YES" or "NO"),
    " Interval     : " .. (state.auto_minutes and (state.auto_minutes .. " min") or "N/A"),
    " Queue Size   : " .. tostring(#sender.queue),
    "",
    " Server       : checking...",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width  = 34
  local height = #lines

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = 5,
    col = 5,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })
end

return M

