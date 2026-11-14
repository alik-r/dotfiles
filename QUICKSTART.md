# Quick start

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/alik-r/dotfiles/main/install.sh | bash
```

Everything installs into `~/.local` without root, except `git curl tmux unzip make gcc`,
which are installed with apt if missing. Safe to re-run.

**After installing:**
```bash
exec bash    # load aliases and PATH
```

**Font (on the machine your terminal runs on, e.g. WSL):**
```bash
curl -fsSL https://raw.githubusercontent.com/alik-r/dotfiles/main/install.sh | bash -s -- --font-only
```
Then restart Windows Terminal.

## Daily use

```bash
t                     # pick a project under ~ -> session with nvim and a shell window
t ~/path/to/project   # open any other folder directly
```
After a disconnect or closing the terminal: `tmux attach`.

## tmux (prefix = `Ctrl+a`)

| Keys | Action |
|---|---|
| `prefix f` | switch or create a project session |
| `prefix S` | new plain shell session (asks for a name) |
| `prefix s` | list sessions |
| `prefix c` / `prefix 1-9` | new window / go to window |
| `prefix \|` / `prefix -` | split side by side / top and bottom |
| `Ctrl+h/j/k/l` | move between panes and Neovim splits |
| `prefix H/J/K/L` | resize the current pane |
| `prefix z` | zoom the current pane |
| `prefix x` | close the current pane |
| `prefix g` | lazygit |
| `prefix [` | scroll and copy mode (`v` select, `y` copy) |
| `prefix d` | detach |
| `prefix Ctrl+l` | clear the shell (plain `Ctrl+l` moves between panes) |
| `prefix r` | reload `tmux.conf` |

## Neovim (leader = `Space`; press it and wait to see every key)

| VS Code | Neovim |
|---|---|
| Ctrl+P (files) | `Space s f` |
| Ctrl+Shift+F (grep) | `Space s g` (word under cursor: `Space s w`) |
| Open tabs | `Space Space` (buffers) |
| Recent files | `Space s .` |
| Explorer | `\` (toggle neo-tree; `a` new file, `?` help) |
| F12 go to definition | `grd` (back: `Ctrl+o`) |
| Shift+F12 references | `grr` |
| Go to implementation | `gri` |
| Hover docs | `K` |
| F2 rename | `grn` |
| Ctrl+. quick fix | `gra` |
| Ctrl+Shift+O symbols | `gO` (workspace: `gW`) |
| Problems panel | `Space s d`, next/prev `]d` / `[d` |
| Format | `Space f` (auto on save: Go, Terraform, Lua) |
| Completion | `Ctrl+n/p` select, `Ctrl+y` accept, `Ctrl+Space` open |
| Source control | `Space g g` (lazygit), `Space g s` changed files |
| GitLens blame | `Space h b` line, `Space g b` file, `Space t b` inline toggle |
| Next/prev change | `]c` / `[c`; stage/reset hunk `Space h s` / `Space h r`; preview `Space h p` |
| Command palette | `Space s c`; all keymaps `Space s k` |
| Save / close | `:w` / `:q` |

## Maintenance

- Update plugins: `:lua vim.pack.update()`, press `:w` to confirm, then commit `nvim/nvim-pack-lock.json`.
- Language servers and tools: `:Mason`.
- Something broken: `:checkhealth`.
