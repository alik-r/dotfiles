# dotfiles

Neovim + tmux dev setup for Go, Terraform, Ansible, YAML and Bash.

```bash
curl -fsSL https://raw.githubusercontent.com/alik-r/dotfiles/main/install.sh | bash
# or
git clone https://github.com/alik-r/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

No root needed: tools go into `~/.local`. If `git curl tmux unzip make gcc` are missing it
installs them with `apt` (asks for sudo). Re-running is safe; bump versions at the top of
`install.sh` to upgrade.

**Font (client side):** icons need a Nerd Font on the machine your *terminal* runs on.
`install.sh` handles it automatically (`scripts/nerd-font.sh`):

- **WSL**: installs JetBrainsMono Nerd Font Mono into Windows (per-user, no admin) and sets it
  as Windows Terminal's default font. Restart Windows Terminal afterwards.
- **Linux desktop**: installs into `~/.local/share/fonts`; select it in your terminal.
- **SSH server**: skipped. On the machine you SSH from, run `install.sh --font-only`
  (or `curl -fsSL .../install.sh | bash -s -- --font-only`).

## Layout

| Path | Linked to | What |
|---|---|---|
| `nvim/` | `~/.config/nvim` | [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (base commit `8e35dbe`) + changes marked `[dotfiles]` |
| `nvim/lua/custom/` | | my additions: tmux navigation, lazygit, Ansible filetypes, OSC 52 clipboard, installer bootstrap |
| `nvim/nvim-pack-lock.json` | | pinned plugin versions (commit it) |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | prefix `Ctrl+a` |
| `bin/tmux-sessionizer` | `~/.local/bin/` | fuzzy project → tmux session |
| `shell/bashrc` | sourced from `~/.bashrc` | PATH, `EDITOR=nvim`, fzf keys, aliases |

Installed tools: nvim, ripgrep, fd, fzf, lazygit, tree-sitter CLI.
LSPs/formatters via Mason (`:Mason`): gopls, terraformls, yamlls (+SchemaStore), ansiblels
(+ansible-lint, ansible-core), bashls (+shellcheck), lua_ls, goimports, shfmt, stylua.

## Workflow

One tmux session per project: `t` (or `prefix f` inside tmux) → pick a dir under `~` →
session with window 1 `nvim .` and window 2 a shell. Sessions survive SSH disconnects:
`tmux attach`.

## Cheatsheet

Leader is `Space`. Press it and wait: which-key shows everything.

### tmux (`prefix` = `Ctrl+a`)

| Keys | Action |
|---|---|
| `prefix f` | jump to/create project session |
| `prefix s` | list sessions |
| `prefix c` / `prefix 1..9` | new window / go to window |
| `prefix \|` / `prefix -` | split vertical / horizontal |
| `Ctrl+h/j/k/l` | move between panes **and** nvim splits |
| `prefix H/J/K/L` | resize pane |
| `prefix z` | zoom pane |
| `prefix g` | lazygit popup |
| `prefix [` | scroll/copy mode (`v` select, `y` copy) |
| `prefix d` | detach |
| `prefix Ctrl+l` | clear shell (plain `Ctrl+l` navigates) |

### Neovim

| VS Code | Neovim |
|---|---|
| Ctrl+P (files) | `Space s f` |
| Ctrl+Shift+F (grep) | `Space s g` (word under cursor: `Space s w`) |
| Open tabs | `Space Space` (buffers) |
| Recent files | `Space s .` |
| Explorer | `\` (toggle neo-tree; `?` inside for help) |
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

New to Vim motions? Run `:Tutor` once.

## Notes

- **Ansible**: YAML under `playbooks/`, `roles/`, `tasks/`, `handlers/` or next to an
  `ansible.cfg` gets filetype `yaml.ansible` → ansiblels instead of yamlls
  (`nvim/lua/custom/plugins/filetypes.lua`). Ansible itself comes from Mason's ansible-lint venv.
- **YAML schemas**: automatic for well-known files (GitHub Actions, compose, Chart.yaml, ...).
  Others: `# yaml-language-server: $schema=<url>` at the top.
- **Clipboard over SSH**: yanks are sent to your local clipboard via OSC 52; paste from local
  with your terminal's paste key.
- **Updating plugins**: `:lua vim.pack.update()` → review → `:w`. Commit `nvim/nvim-pack-lock.json`.
- **Health check**: `:checkhealth`.
