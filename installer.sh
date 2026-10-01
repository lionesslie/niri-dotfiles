#!/usr/bin/env bash
# ============================================================
# installer.sh — lionesslie/niri-dotfiles (minimal)
# Arch Linux için kurulum scripti
# ============================================================
set -euo pipefail

info()    { echo -e "\033[1;36m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*"; exit 1; }

# ── Paketler ─────────────────────────────────────────────────

PACMAN_PACKAGES=(
  niri
  xwayland-satellite
  xdg-desktop-portal-gnome
  polkit-gnome
  swaylock
  pipewire
  wireplumber
  playerctl
  brightnessctl
  alacritty
  fish
  neovim
  rofi
  thunar
  udiskie
  udisks2
  networkmanager
  libnotify
  ttf-jetbrains-mono-nerd
  papirus-icon-theme
  steam
  gamemode
)

AUR_PACKAGES=(
  nvibrant
  zen-browser-bin
)

# Repodan ~/.config'e kopyalanmayacak klasörler
SKIP_DIRS=(assets .git .github)

# ── Kontroller ───────────────────────────────────────────────

command -v pacman &>/dev/null || error "Bu script yalnızca Arch Linux içindir."
sudo -v || error "sudo yetkisi gerekli."

if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
  warn "multilib etkin değil, steam kurulamayabilir (/etc/pacman.conf)."
fi

# ── Kurulum ──────────────────────────────────────────────────

info "Paketler kuruluyor..."
sudo pacman -S --needed --noconfirm git base-devel "${PACMAN_PACKAGES[@]}" \
  || warn "Bazı pacman paketleri kurulamadı."

if ! command -v yay &>/dev/null; then
  info "yay kuruluyor..."
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

info "AUR paketleri kuruluyor..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" \
  || warn "Bazı AUR paketleri kurulamadı."

sudo systemctl enable --now NetworkManager \
  || warn "NetworkManager etkinleştirilemedi."

# ── Dotfiles ─────────────────────────────────────────────────

REPO_DIR="$HOME/.cache/niri-dotfiles-install"
CONFIG_DIR="$HOME/.config"

rm -rf "$REPO_DIR"
git clone --depth=1 https://github.com/lionesslie/niri-dotfiles "$REPO_DIR"
mkdir -p "$CONFIG_DIR"

src="$REPO_DIR"
[[ -d "$REPO_DIR/.config" ]] && src="$REPO_DIR/.config"

for dir in "$src"/*/; do
  name=$(basename "$dir")
  [[ " ${SKIP_DIRS[*]} " == *" $name "* ]] && continue

  target="$CONFIG_DIR/$name"
  if [[ -e "$target" ]]; then
    mv "$target" "${target}.bak-$(date +%Y%m%d%H%M%S)"
    warn "Yedeklendi: $name"
  fi
  cp -r "$dir" "$target"
  success "$name → ~/.config/$name"
done

rm -rf "$REPO_DIR"

# ── Fish (opsiyonel) ─────────────────────────────────────────

read -rp "Fish varsayılan shell olsun mu? [e/H]: " answer
if [[ "$answer" =~ ^[Ee]$ ]]; then
  fish_path=$(command -v fish)
  grep -qF "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$fish_path"
fi

success "Kurulum tamamlandı. Oturumu kapatıp niri ile giriş yap."
