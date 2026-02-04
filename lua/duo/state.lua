-- lua/duo/state.lua
local M = {}

-- 🔥 SINGLE SOURCE OF TRUTH
M.state = {
  -- lifecycle
  running = false,

  -- auto sync
  auto_sync = false,
  auto_minutes = nil,
  timer = nil,

  -- server / sync
  server_online = false,
  last_sync = nil,

  -- data
  queue = {},

  -- stats (for profile UI later)
  stats = {
    sent = 0,
    failed = 0,
  },
}

-- =========================
-- Lifecycle
-- =========================
function M.start()
  M.state.running = true
end

function M.stop()
  M.state.running = false
end

-- =========================
-- Auto sync
-- =========================
function M.enable_auto(minutes)
  M.state.auto_sync = true
  M.state.auto_minutes = minutes
end

function M.disable_auto()
  M.state.auto_sync = false
  M.state.auto_minutes = nil
end

-- =========================
-- Queue handling
-- =========================
function M.push(item)
  table.insert(M.state.queue, item)
end

function M.clear_queue()
  M.state.queue = {}
end

function M.queue_size()
  return #M.state.queue
end

-- =========================
-- Sync helpers
-- =========================
function M.mark_synced()
  M.state.last_sync = os.date("%Y-%m-%d %H:%M:%S")
end

-- =========================
-- Getter (read-only usage)
-- =========================
function M.get()
  return M.state
end

return M

