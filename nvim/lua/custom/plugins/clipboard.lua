-- Over SSH there is no system clipboard on the server, so yanks go to your *local*
-- clipboard through the terminal (OSC 52). Works through tmux (set-clipboard on).
-- `p` pastes the last yank as usual; to paste from your local clipboard use your
-- terminal's paste shortcut (Ctrl+Shift+V / Cmd+V) in insert mode.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require 'vim.ui.clipboard.osc52'
  local last = { {}, 'v' }
  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      last = { lines, regtype }
      send(lines, regtype)
    end
  end
  local function paste() return last end
  vim.g.clipboard = {
    name = 'OSC 52 (copy only)',
    copy = { ['+'] = copy '+', ['*'] = copy '*' },
    paste = { ['+'] = paste, ['*'] = paste },
  }
end
