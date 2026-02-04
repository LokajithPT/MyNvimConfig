local M = {}
local state = require("duo.state")

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
    filename = item.file or "unknown",
    typed = "typed " .. (item.count or 0) .. " chars",
    pasted = "",
    real = item.type or "typed"
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
    return true
  else
    vim.notify("HTTP " .. http_code .. ": " .. response, vim.log.levels.ERROR)
    return false
  end
end

return M

