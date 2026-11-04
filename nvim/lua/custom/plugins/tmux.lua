-- Ctrl+h/j/k/l moves between Neovim splits AND tmux panes seamlessly.
-- The tmux half of this lives in tmux/tmux.conf.
-- https://github.com/christoomey/vim-tmux-navigator
vim.g.tmux_navigator_no_mappings = 1
vim.pack.add { 'https://github.com/christoomey/vim-tmux-navigator' }

vim.keymap.set('n', '<C-h>', '<Cmd>TmuxNavigateLeft<CR>', { desc = 'Move focus left (split or tmux pane)' })
vim.keymap.set('n', '<C-j>', '<Cmd>TmuxNavigateDown<CR>', { desc = 'Move focus down (split or tmux pane)' })
vim.keymap.set('n', '<C-k>', '<Cmd>TmuxNavigateUp<CR>', { desc = 'Move focus up (split or tmux pane)' })
vim.keymap.set('n', '<C-l>', '<Cmd>TmuxNavigateRight<CR>', { desc = 'Move focus right (split or tmux pane)' })
