# Quick start

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/alik-r/dotfiles/main/install.sh | bash
```

Everything installs into `~/.local` without root, except `git curl tmux unzip make gcc`,
which are installed with apt if missing. Safe to re-run.

**First time on a server:**
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
t                     # pick a project -> session with nvim and a shell window
```
After a disconnect: `tmux attach`.

## tmux (prefix = `Ctrl+a`)

| Keys | Action |
|---|---|
| `prefix f` | switch or create a project session |
| `prefix S` | new plain shell session (asks for a name) |
| `prefix s` | list sessions |
| `prefix c` / `prefix 1-9` | new window / go to window |
| `prefix \|` / `prefix -` | split side by side / top and bottom |
| `Ctrl+h/j/k/l` | move between panes and Neovim splits |
| `prefix z` | zoom the current pane |
| `prefix g` | lazygit |
| `prefix [` | scroll and copy mode (`v` select, `y` copy) |
| `prefix d` | detach |

## Neovim (leader = `Space`; press it and wait to see every key)

| Task | Keys |
|---|---|
| Find file / grep text / open buffers | `Space s f` / `Space s g` / `Space Space` |
| File tree | `\` |
| Definition / references / rename / code action | `grd` / `grr` / `grn` / `gra` |
| Hover docs / jump back | `K` / `Ctrl+o` |
| Diagnostics list / next / previous | `Space s d` / `]d` / `[d` |
| Format | `Space f` |
| Completion: next / previous / accept | `Ctrl+n` / `Ctrl+p` / `Ctrl+y` |
| lazygit / blame line / next change | `Space g g` / `Space h b` / `]c` |
| Save / quit | `:w` / `:q` |

Full VS Code → Neovim key mapping: [README.md](README.md#cheatsheet).

## Maintenance

- Update plugins: `:lua vim.pack.update()`, press `:w` to confirm, then commit `nvim/nvim-pack-lock.json`.
- Language servers and tools: `:Mason`.
- Something broken: `:checkhealth`.
