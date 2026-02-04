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
      local filename = vim.fn.expand("%:p")
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local current_content = table.concat(lines, "\n")

  -- Initialize session for this file if not exists
  if not file_sessions[filename] then
    file_sessions[filename] = {
      initial_content = current_content,
      typed = "",
      pasted = "",
      deleted = "",
      manual = "",
      last_content = current_content
    }
    return
  end

      local session = file_sessions[filename]
      local prev_content = session.last_content
      
      -- Detect changes (additions and deletions)
      if #current_content >= #prev_content then
        local addition = current_content:sub(#prev_content + 1)
        
        -- Better paste detection
        if vim.fn.mode() == "i" then
          -- Check if this looks like a paste (large chunk at once)
          if #addition > 10 or addition:match("\n") then
            session.pasted = session.pasted .. addition
          else
            session.typed = session.typed .. addition
          end
        else
          -- Not in insert mode, assume pasted
          session.pasted = session.pasted .. addition
        end
      elseif #current_content < #prev_content then
        -- Content was deleted - track what was removed
        local deletion = session.last_content:sub(#current_content + 1)
        if session.deleted == nil then
          session.deleted = ""
        end
        session.deleted = session.deleted .. deletion
      end

      -- Update session state
      session.last_content = current_content
      
      -- Detect manual edits (content that wasn't typed or pasted)
      local manual = ""
      if session.initial_content ~= current_content and session.typed == "" and session.pasted == "" then
        manual = current_content
      end
      
      -- Update the state with current session data
      state.push({
        type = "file_change",
        filename = filename,
        typed = session.typed,
        pasted = session.pasted,
        deleted = session.deleted or "",
        manual = manual,
        real = current_content,
        ts = os.time(),
      })
    end,
  })
end

-- Function to clear session for a file (call after successful sync)
function M.clear_session(filename)
  if file_sessions[filename] then
    -- Keep all typed/pasted content - only reset tracking state
    local session = file_sessions[filename]
    session.initial_content = session.last_content
    session.deleted = ""
    session.manual = ""
    -- DO NOT clear typed and pasted - keep accumulating!
  end
end

-- Function to get all active sessions
function M.get_sessions()
  return file_sessions
end

return M

