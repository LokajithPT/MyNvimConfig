local M = {}

local state  = require("duo.state")
local sender = require("duo.sender")

local uv = vim.loop

local function start_timer(minutes)
  if state.timer then
    state.timer:stop()
    state.timer:close()
  end

  local interval = minutes * 60 * 1000
  state.timer = uv.new_timer()

  state.timer:start(
    interval,
    interval,
    vim.schedule_wrap(function()
      if state.running then
        sender.flush()
      end
    end)
  )
end

function M.setup()

  -- DuoStart
  vim.api.nvim_create_user_command("DuoStart", function()
    state.start()
    vim.notify("Duo started 🚀", vim.log.levels.INFO)

    if state.auto_sync and state.auto_minutes then
      start_timer(state.auto_minutes)
    end
  end, {})

  -- DuoStop
  vim.api.nvim_create_user_command("DuoStop", function()
    state.stop()

    if state.timer then
      state.timer:stop()
      state.timer:close()
      state.timer = nil
    end

    vim.notify("Duo stopped 🛑", vim.log.levels.WARN)
  end, {})

  -- DuoSync
  vim.api.nvim_create_user_command("DuoSync", function()
    sender.flush()
    vim.notify("Duo sync triggered 🔄", vim.log.levels.INFO)
  end, {})

  -- DuoAuto <minutes>
  vim.api.nvim_create_user_command("DuoAuto", function(opts)
    local mins = tonumber(opts.args)

    if not mins or mins <= 0 then
      vim.notify("Usage: DuoAuto <minutes>", vim.log.levels.ERROR)
      return
    end

    state.enable_auto(mins)
    start_timer(mins)

    vim.notify("Auto sync every " .. mins .. " min ⏱️", vim.log.levels.INFO)
  end, { nargs = 1 })

  -- DuoProfile
  vim.api.nvim_create_user_command("DuoProfile", function()
    require("duo.profile").open()
  end, {})
end

return M

