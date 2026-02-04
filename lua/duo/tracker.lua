-- lua/duo/tracker.lua
local M = {}
local state = require("duo.state")

local last_len = 0

function M.setup()
  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      local s = state.get()
      if not s.running then return end

      local buf = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local text = table.concat(lines, "\n")

      local delta = #text - last_len
      if delta > 0 then
        state.push({
          type = "typed",
          count = delta,
          file = vim.fn.expand("%"),
          ts = os.time(),
        })
      end

      last_len = #text
    end,
  })
end

return M

