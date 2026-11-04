#!/usr/bin/env bash
# Dotfiles installer: Neovim + tmux dev workflow.
#
#   curl -fsSL https://raw.githubusercontent.com/alik-r/dotfiles/main/install.sh | bash
#   # or, from a clone:
#   ~/dotfiles/install.sh
#
#   install.sh --font-only   # only the Nerd Font (run on the machine your terminal runs on,
#                            # e.g. in WSL: installs into Windows + sets Windows Terminal font)
#
# Idempotent: safe to re-run. Installs CLI tools into ~/.local (no root needed),
# symlinks configs, and backs up anything it would replace.
# Bump the versions below to upgrade.
set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/alik-r/dotfiles.git}"
DOTFILES="${DOTFILES:-$HOME/dotfiles}"

NVIM_VERSION=0.12.6
RG_VERSION=15.2.0
FD_VERSION=10.5.0
FZF_VERSION=0.74.5
LAZYGIT_VERSION=0.66.2
TREESITTER_VERSION=0.27.1

BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- bootstrap: when piped from curl, clone the repo first --------------------
if [[ ! -f "$DOTFILES/install.sh" ]]; then
  have git || { warn "git is required"; exit 1; }
  info "Cloning $REPO_URL -> $DOTFILES"
  git clone "$REPO_URL" "$DOTFILES"
  exec bash "$DOTFILES/install.sh" "$@"
fi

if [[ "${1:-}" == --font-only ]]; then
  exec bash "$DOTFILES/scripts/nerd-font.sh"
fi

case "$(uname -m)" in
  x86_64 | amd64) ARCH=x86_64 ;;
  aarch64 | arm64) ARCH=arm64 ;;
  *) warn "unsupported arch $(uname -m)"; exit 1 ;;
esac

mkdir -p "$BIN" "$OPT" "$HOME/.config"
export PATH="$BIN:$PATH"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fetch() { curl -fsSL --retry 3 -o "$2" "$1"; }

# --- system packages (only if missing; needs sudo) ----------------------------
# unzip: Mason extracts several LSPs from .zip; make+gcc: telescope-fzf-native,
# treesitter parsers.
missing=()
for p in git curl tmux unzip make gcc; do have "$p" || missing+=("$p"); done
if ((${#missing[@]})); then
  if have apt-get && { sudo -n true 2>/dev/null || [[ -t 0 ]]; }; then
    info "Installing system packages: ${missing[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y "${missing[@]}"
  else
    warn "Missing system packages: ${missing[*]} - install them with your package manager"
  fi
fi

# --- user-local binaries ------------------------------------------------------
# Neovim
if [[ "$(nvim --version 2>/dev/null | head -1)" != "NVIM v$NVIM_VERSION" ]]; then
  info "Installing Neovim $NVIM_VERSION"
  fetch "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/nvim-linux-$ARCH.tar.gz" "$TMP/nvim.tgz"
  rm -rf "$OPT/nvim"
  mkdir -p "$OPT/nvim"
  tar -xzf "$TMP/nvim.tgz" -C "$OPT/nvim" --strip-components=1
  ln -sfn "$OPT/nvim/bin/nvim" "$BIN/nvim"
fi

# ripgrep (Telescope live grep)
if [[ "$(rg --version 2>/dev/null | head -1)" != "ripgrep $RG_VERSION"* ]]; then
  info "Installing ripgrep $RG_VERSION"
  a=$([[ $ARCH == arm64 ]] && echo aarch64 || echo x86_64)
  fetch "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-$a-unknown-linux-musl.tar.gz" "$TMP/rg.tgz"
  tar -xzf "$TMP/rg.tgz" -C "$TMP"
  install -m 755 "$TMP/ripgrep-$RG_VERSION-$a-unknown-linux-musl/rg" "$BIN/rg"
fi

# fd (Telescope find files)
if [[ "$(fd --version 2>/dev/null)" != "fd $FD_VERSION" ]]; then
  info "Installing fd $FD_VERSION"
  a=$([[ $ARCH == arm64 ]] && echo aarch64 || echo x86_64)
  fetch "https://github.com/sharkdp/fd/releases/download/v$FD_VERSION/fd-v$FD_VERSION-$a-unknown-linux-musl.tar.gz" "$TMP/fd.tgz"
  tar -xzf "$TMP/fd.tgz" -C "$TMP"
  install -m 755 "$TMP/fd-v$FD_VERSION-$a-unknown-linux-musl/fd" "$BIN/fd"
fi

# fzf (tmux-sessionizer, shell Ctrl-R / Ctrl-T)
if [[ "$(fzf --version 2>/dev/null | cut -d' ' -f1)" != "$FZF_VERSION" ]]; then
  info "Installing fzf $FZF_VERSION"
  a=$([[ $ARCH == arm64 ]] && echo arm64 || echo amd64)
  fetch "https://github.com/junegunn/fzf/releases/download/v$FZF_VERSION/fzf-$FZF_VERSION-linux_$a.tar.gz" "$TMP/fzf.tgz"
  tar -xzf "$TMP/fzf.tgz" -C "$TMP"
  install -m 755 "$TMP/fzf" "$BIN/fzf"
fi

# lazygit
if [[ "$(lazygit --version 2>/dev/null)" != *"version=$LAZYGIT_VERSION,"* ]]; then
  info "Installing lazygit $LAZYGIT_VERSION"
  fetch "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_${LAZYGIT_VERSION}_linux_$ARCH.tar.gz" "$TMP/lg.tgz"
  tar -xzf "$TMP/lg.tgz" -C "$TMP" lazygit
  install -m 755 "$TMP/lazygit" "$BIN/lazygit"
fi

# tree-sitter CLI (nvim-treesitter `main` compiles parsers with it)
if [[ "$(tree-sitter --version 2>/dev/null)" != "tree-sitter $TREESITTER_VERSION"* ]]; then
  info "Installing tree-sitter CLI $TREESITTER_VERSION"
  a=$([[ $ARCH == arm64 ]] && echo arm64 || echo x64)
  fetch "https://github.com/tree-sitter/tree-sitter/releases/download/v$TREESITTER_VERSION/tree-sitter-linux-$a.gz" "$TMP/ts.gz"
  gunzip -c "$TMP/ts.gz" >"$TMP/tree-sitter"
  install -m 755 "$TMP/tree-sitter" "$BIN/tree-sitter"
fi

# --- symlink configs ----------------------------------------------------------
link() { # link <source in repo> <target>
  local src="$DOTFILES/$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then return; fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    local bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backing up $dst -> $bak"
    mv "$dst" "$bak"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  info "Linked $dst"
}

link nvim "$HOME/.config/nvim"
link tmux/tmux.conf "$HOME/.config/tmux/tmux.conf"
link bin/tmux-sessionizer "$BIN/tmux-sessionizer"

# Shell: one source line in ~/.bashrc, everything else lives in the repo.
SRC_LINE="[ -f \"$DOTFILES/shell/bashrc\" ] && . \"$DOTFILES/shell/bashrc\""
if ! grep -qF "$DOTFILES/shell/bashrc" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# dotfiles\n%s\n' "$SRC_LINE" >>"$HOME/.bashrc"
  info "Added dotfiles source line to ~/.bashrc"
fi

# --- Neovim plugins, parsers, LSPs (headless) ---------------------------------
if [[ "${SKIP_NVIM_BOOTSTRAP:-}" != 1 ]]; then
  info "Installing Neovim plugins, treesitter parsers and LSP servers (first run takes a few minutes)"
  NVIM_BOOTSTRAP=1 nvim --headless -c 'lua require("custom.bootstrap").run()' -c 'qa' 2>&1 | sed 's/^/    /' || warn "Neovim bootstrap reported errors; open nvim and run :checkhealth"
fi

# --- Nerd Font (where the terminal runs; skipped on SSH servers) ------------------
bash "$DOTFILES/scripts/nerd-font.sh" || warn "Nerd Font install failed; retry with: install.sh --font-only"

info "Done. Open a new shell (or: source ~/.bashrc), then run: tmux"
