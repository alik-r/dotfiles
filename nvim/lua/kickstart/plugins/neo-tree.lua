-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  filesystem = {
    -- [dotfiles] VS Code-like: highlight the open file, show dotfiles, dim gitignored files
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
    filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
