-- lua/duo/init.lua
local state = require("duo.state")
local tracker = require("duo.tracker")
local commands = require("duo.commands")

local M = {}

function M.setup(opts)
  -- 🔒 HARD SAFETY
  opts = opts or {}
  if opts == true then opts = {} end

  -- defaults
  local auto_sync = opts.auto_sync or false
  local auto_minutes = opts.auto_minutes or 5

  -- start core
  state.start()

  if auto_sync then
    state.enable_auto(auto_minutes)
  end

  -- init other modules
  tracker.setup()
  commands.setup()
end

return M

