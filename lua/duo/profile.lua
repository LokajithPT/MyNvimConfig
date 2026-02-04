-- lua/duo/profile.lua
local M = {}
local state = require("duo.state")

function M.open()
  local s = state.get()

  -- HARD GUARDS (important)
  local queue = s.queue or {}
  local stats = s.stats or {}

  local lines = {
    " Duo Profile",
    "────────────────────",
    "Status       : " .. (s.running and "Running" or "Stopped"),
    "Server       : " .. (s.server_online and "Online" or "Offline"),
    "",
    "Queue size   : " .. tostring(#queue),
    "Last sync    : " .. (s.last_sync or "never"),
    "",
    "Stats",
    "Sent         : " .. tostring(stats.sent or 0),
    "Failed       : " .. tostring(stats.failed or 0),
  }

  vim.api.nvim_echo(
    vim.tbl_map(function(l) return { l, "Normal" } end, lines),
    false,
    {}
  )
end

return M

