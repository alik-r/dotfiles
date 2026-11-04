#!/usr/bin/env bash
# Install JetBrainsMono Nerd Font Mono where your *terminal* runs and select it.
#   WSL           -> installs into Windows (per-user, no admin) + sets Windows Terminal's font
#   Linux desktop -> ~/.local/share/fonts
#   SSH server    -> skipped (the font is needed on the machine you SSH from, not here)
# Run standalone or via: install.sh --font-only
set -euo pipefail

FONT_VERSION="${NERD_FONT_VERSION:-3.5.1}"
FACE="JetBrainsMono Nerd Font Mono"
FILES=(JetBrainsMonoNerdFontMono-Regular.ttf JetBrainsMonoNerdFontMono-Bold.ttf
  JetBrainsMonoNerdFontMono-Italic.ttf JetBrainsMonoNerdFontMono-BoldItalic.ttf)

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }

is_wsl() { [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; }

if is_wsl; then
  target=wsl
elif [[ -n "${SSH_CONNECTION:-}${SSH_TTY:-}" && -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
  info "Nerd Font: skipped on SSH server - install it where your terminal runs (WSL: run install.sh --font-only there)"
  exit 0
else
  target=linux
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
download() {
  info "Downloading JetBrainsMono Nerd Font v$FONT_VERSION"
  curl -fsSL --retry 3 -o "$TMP/font.tar.xz" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v$FONT_VERSION/JetBrainsMono.tar.xz"
  tar -xJf "$TMP/font.tar.xz" -C "$TMP" "${FILES[@]}"
}

# --- Linux desktop ---------------------------------------------------------------
if [[ $target == linux ]]; then
  dir="$HOME/.local/share/fonts"
  if [[ -f "$dir/${FILES[0]}" ]]; then info "Nerd Font already installed"; exit 0; fi
  download
  mkdir -p "$dir"
  cp "${FILES[@]/#/$TMP/}" "$dir/"
  command -v fc-cache >/dev/null && fc-cache -f "$dir" >/dev/null
  info "Installed '$FACE' - select it in your terminal's settings"
  exit 0
fi

# --- WSL: install into Windows ---------------------------------------------------
lad_win=$(powershell.exe -NoProfile -NonInteractive -Command '[Environment]::GetFolderPath("LocalApplicationData")' 2>/dev/null | tr -d '\r')
[[ -n "$lad_win" ]] || { warn "Could not reach Windows (powershell.exe) - is WSL interop enabled?"; exit 1; }
LAD=$(wslpath -u "$lad_win")
fontdir="$LAD/Microsoft/Windows/Fonts"
mkdir -p "$fontdir"

need=0
for f in "${FILES[@]}"; do [[ -f "$fontdir/$f" ]] || need=1; done
if ((need)); then
  download
  for f in "${FILES[@]}"; do
    [[ -f "$fontdir/$f" ]] || cp "$TMP/$f" "$fontdir/$f"
    # Per-user font registration (what "Install for me" does in Explorer)
    reg.exe add 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts' \
      /v "${f%.ttf} (TrueType)" /t REG_SZ /d "$(wslpath -w "$fontdir/$f")" /f >/dev/null
  done
  info "Installed '$FACE' into Windows (per-user)"
else
  info "Nerd Font already installed in Windows"
fi

# Windows Terminal: set the default font for all profiles (stable, preview, unpackaged)
found=0
for s in "$LAD"/Packages/Microsoft.WindowsTerminal*_8wekyb3d8bbwe/LocalState/settings.json \
  "$LAD/Microsoft/Windows Terminal/settings.json"; do
  [[ -f "$s" ]] || continue
  found=1
  python3 - "$s" "$FACE" <<'PY' || warn "Could not update $s - set the font manually: Settings > Defaults > Appearance > Font face"
import json, shutil, sys
path, face = sys.argv[1], sys.argv[2]
try:
    with open(path, encoding="utf-8-sig") as fh:
        data = json.load(fh)
except ValueError:
    sys.exit(1)  # has comments / not plain JSON: don't rewrite it, caller prints manual step
profiles = data.setdefault("profiles", {})
if isinstance(profiles, list):
    profiles = data["profiles"] = {"list": profiles}
font = profiles.setdefault("defaults", {}).setdefault("font", {})
if font.get("face") == face:
    print(f"==> Windows Terminal already uses '{face}'")
    sys.exit(0)
shutil.copy2(path, path + ".bak-dotfiles")
font["face"] = face
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=4, ensure_ascii=False)
    fh.write("\n")
print(f"==> Windows Terminal default font set to '{face}' (backup: settings.json.bak-dotfiles)")
overrides = [p.get("name", "?") for p in profiles.get("list", []) if p.get("font", {}).get("face") not in (None, face)]
if overrides:
    print(f"!!  These profiles set their own font and will not change: {', '.join(overrides)}")
PY
done
((found)) || info "Windows Terminal settings not found - in your terminal, select font '$FACE'"
info "Restart Windows Terminal to pick up the new font"
