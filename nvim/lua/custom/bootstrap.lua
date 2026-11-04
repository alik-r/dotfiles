-- Headless first-time setup, run by install.sh:
--   NVIM_BOOTSTRAP=1 nvim --headless -c 'lua require("custom.bootstrap").run()' -c qa
-- Plugins are already installed while init.lua loads; this waits for LSP servers,
-- formatters and treesitter parsers so the first real start is instant.
local M = {}

local function step(name, fn)
  print(name .. '...')
  local ok, err = pcall(fn)
  if not ok then print('  FAILED: ' .. tostring(err):gsub('\n.*', '')) end
end

function M.run()
  step('Installing Mason tools (LSP servers, formatters, linters)', function() vim.cmd 'MasonToolsInstallSync' end)
  step('Installing treesitter parsers', function()
    if not require('nvim-treesitter').install(require 'custom.parsers'):wait(600000) then error 'install failed or timed out' end
  end)
  print 'Bootstrap finished. Retry anything that failed with :MasonToolsInstall / :TSUpdate'
end

return M
