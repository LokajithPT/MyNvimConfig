local M = {}

M.running = false
M.auto_sync = false
M.auto_minutes = nil
M.timer = nil

function M.start()
  M.running = true
end

function M.stop()
  M.running = false
end

function M.enable_auto(minutes)
  M.auto_sync = true
  M.auto_minutes = minutes
end

function M.disable_auto()
  M.auto_sync = false
  M.auto_minutes = nil
end

return M

