-- lua/duo/tracker.lua
local M = {}
local state = require("duo.state")

-- Session tracking per file
local file_sessions = {}

function M.setup()
  vim.api.nvim_create_autocmd({"TextChangedI", "TextChangedP"}, {
    callback = function()
      local s = state.get()
      if not s.running then return end

      local buf = vim.api.nvim_get_current_buf()
      local filename = vim.fn.expand("%:t")
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local current_content = table.concat(lines, "\n")

      -- Initialize session for this file if not exists
      if not file_sessions[filename] then
        file_sessions[filename] = {
          initial_content = current_content,
          typed = "",
          pasted = "",
          last_content = current_content
        }
        return
      end

      local session = file_sessions[filename]
      local prev_content = session.last_content
      
      -- Detect new additions
      if #current_content > #prev_content then
        local addition = current_content:sub(#prev_content + 1)
        
        if vim.fn.mode() == "i" then
          -- In insert mode, assume typed
          session.typed = session.typed .. addition
        else
          -- Not in insert mode, assume pasted
          session.pasted = session.pasted .. addition
        end
      end

      -- Update session state
      session.last_content = current_content
      
      -- Update the state with current session data
      state.push({
        type = "file_change",
        filename = filename,
        typed = session.typed,
        pasted = session.pasted,
        real = current_content,
        ts = os.time(),
      })
    end,
  })
end

-- Function to clear session for a file (call after successful sync)
function M.clear_session(filename)
  if file_sessions[filename] then
    -- Reset session but keep current content as new baseline
    local current_content = file_sessions[filename].last_content
    file_sessions[filename] = {
      initial_content = current_content,
      typed = "",
      pasted = "",
      last_content = current_content
    }
  end
end

-- Function to get all active sessions
function M.get_sessions()
  return file_sessions
end

return M

