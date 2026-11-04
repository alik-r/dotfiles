-- lazygit: full git UI (stage, commit, branches, log, rebase).
-- Inside tmux it opens as a tmux popup (same as `prefix g`), otherwise in a Neovim tab.
-- Line-level git (hunks, blame) is gitsigns: see the <leader>h keymaps in init.lua.
local function lazygit()
  local cwd = vim.fn.getcwd()
  if vim.env.TMUX then
    vim.system { 'tmux', 'display-popup', '-E', '-w', '90%', '-h', '90%', '-d', cwd, 'lazygit' }
  else
    vim.cmd.tabnew()
    vim.fn.jobstart({ 'lazygit' }, {
      term = true,
      cwd = cwd,
      on_exit = function() vim.cmd 'silent! bdelete!' end,
    })
    vim.cmd.startinsert()
  end
end

vim.keymap.set('n', '<leader>gg', lazygit, { desc = '[G]it: lazy[g]it' })
vim.keymap.set('n', '<leader>gb', '<Cmd>Gitsigns blame<CR>', { desc = '[G]it [b]lame (file)' })
vim.keymap.set('n', '<leader>gs', function() require('telescope.builtin').git_status() end, { desc = '[G]it [s]tatus (changed files)' })
vim.keymap.set('n', '<leader>gc', function() require('telescope.builtin').git_bcommits() end, { desc = '[G]it [c]ommits for this file' })
