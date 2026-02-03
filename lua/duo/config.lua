-- lua/duo/config.lua
local M = {}

M.opts = {
  server_url = "http://localhost:8080",
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M

