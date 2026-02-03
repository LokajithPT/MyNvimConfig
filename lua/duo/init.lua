local M = {}

function M.setup()
  require("duo.config").setup()
  require("duo.commands").setup()
  require("duo.tracker").setup()
end

return M

