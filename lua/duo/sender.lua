local M = {}
local state = require("duo.state")
local tracker = require("duo.tracker")

function M.setup()
  -- config stuff
end

function M.flush()
  local s = state.get()
  
  if not s.running then
    vim.notify("Duo not running", vim.log.levels.WARN)
    return
  end
  
  if state.queue_size() == 0 then
    vim.notify("Nothing to sync", vim.log.levels.INFO)
    return
  end
  
  -- Check server connectivity first
  local server_online = M.check_server()
  if not server_online then
    vim.notify("Server offline - keeping items in queue for later sync 📦", vim.log.levels.WARN)
    s.stats.failed = (s.stats.failed or 0) + state.queue_size()
    return
  end
  
  -- Process each item in queue
  local queue_copy = {}
  for i, item in ipairs(s.queue) do
    table.insert(queue_copy, item)
  end
  
  local success_count = 0
  local failed_count = 0
  
  for _, item in ipairs(queue_copy) do
    local success = M.send_item(item)
    if success then
      success_count = success_count + 1
    else
      failed_count = failed_count + 1
    end
  end
  
  -- Clear queue on success, keep failed items
  if failed_count == 0 then
    -- Update tracker sessions for successfully synced files (accumulate, don't clear)
    local synced_files = {}
    for _, item in ipairs(queue_copy) do
      if item.filename and not synced_files[item.filename] then
        tracker.clear_session(item.filename)
        synced_files[item.filename] = true
      end
    end
    
    state.clear_queue()
    state.mark_synced()
    vim.notify("Synced " .. success_count .. " items ✅", vim.log.levels.INFO)
  else
    vim.notify("Synced " .. success_count .. ", failed " .. failed_count .. " ⚠️", vim.log.levels.WARN)
  end
  
  -- Update stats
  s.stats.sent = (s.stats.sent or 0) + success_count
  s.stats.failed = (s.stats.failed or 0) + failed_count
end

function M.send_item(item)
  local payload = {
    filename = item.filename or item.file or "unknown",
    typed = item.typed or "",
    pasted = item.pasted or "",
    real = item.real or ""
  }
  
  local json_payload = vim.json.encode(payload)
  
  local curl_cmd = {
    "curl",
    "-s", "-w", "%{http_code}",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "-d", json_payload,
    "http://localhost:8080/submit"
  }
  
  local result = vim.fn.system(curl_cmd)
  
  -- Extract HTTP code from result
  local http_code = result:sub(-3)
  local response = result:sub(1, -4)
  
  if http_code == "200" then
    -- Clear tracker session for this file on successful sync
    if item.filename then
      tracker.clear_session(item.filename)
    end
    return true
  else
    -- Don't spam with errors if server is offline
    return false
  end
end

function M.check_server()
  -- Simple ping to check if server is online
  local ping_cmd = {
    "curl",
    "-s", "-w", "%{http_code}",
    "-m", "5", -- 5 second timeout
    "http://localhost:8080/ping"
  }
  
  local result = vim.fn.system(ping_cmd)
  local http_code = result:sub(-3)
  
  return http_code == "200"
end

return M

