#!/usr/bin/env bash
# ============================================================
#  install.sh — lionesslie/niri-dotfiles installer
#  Arch Linux için otomatik kurulum scripti
# ============================================================

set -e

# ── Renkler ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Yardımcı fonksiyonlar ────────────────────────────────────
info()    { echo -e "${CYAN}${BOLD}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}${BOLD}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}${BOLD}[ERROR]${RESET} $*"; exit 1; }

banner() {
  echo -e "${CYAN}${BOLD}"
  echo "  ███╗   ██╗██╗██████╗ ██╗    ██████╗  ██████╗ ████████╗███████╗"
  echo "  ████╗  ██║██║██╔══██╗██║    ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝"
  echo "  ██╔██╗ ██║██║██████╔╝██║    ██║  ██║██║   ██║   ██║   ███████╗"
  echo "  ██║╚██╗██║██║██╔══██╗██║    ██║  ██║██║   ██║   ██║   ╚════██║"
  echo "  ██║ ╚████║██║██║  ██║██║    ██████╔╝╚██████╔╝   ██║   ███████║"
  echo "  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝╚═╝    ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝"
  echo -e "${RESET}"
  echo -e "  ${BOLD}lionesslie/niri-dotfiles${RESET} — Otomatik Kurulum Scripti"
  echo -e "  ${YELLOW}Arch Linux${RESET} için hazırlanmıştır.\n"
}

# ── Arch Linux kontrolü ──────────────────────────────────────
check_arch() {
  if ! command -v pacman &>/dev/null; then
    error "Bu script yalnızca Arch Linux için tasarlanmıştır! pacman bulunamadı."
  fi
  success "Arch Linux tespit edildi."
}

# ── sudo kontrolü ────────────────────────────────────────────
check_sudo() {
  if ! sudo -v &>/dev/null; then
    error "sudo yetkisi gerekli. Lütfen sudo erişiminizi kontrol edin."
  fi
  success "sudo yetkisi doğrulandı."
}

# ── Bağımlılık: git & yay ────────────────────────────────────
install_prerequisites() {
  info "Temel bağımlılıklar kontrol ediliyor (git, base-devel)..."
  sudo pacman -S --needed --noconfirm git base-devel curl

  if ! command -v yay &>/dev/null; then
    info "yay (AUR helper) bulunamadı, kuruluyor..."
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    success "yay başarıyla kuruldu."
  else
    success "yay zaten kurulu."
  fi
}

# ── Pacman paketleri ─────────────────────────────────────────
PACMAN_PACKAGES=(
  alacritty
  rofi
  thunar
  fish
  udiskie
  udisks2
  ttf-jetbrains-mono-nerd
  papirus-icon-theme
  playerctl
  brightnessctl
  networkmanager
  libnotify
  xclip
  flameshot
  firefox
  neovim
  ttf-liberation
  base-devel
  waybar
  steam
  gamemode
)

# ── AUR paketleri (niri resmi repoda olmayabilir) ────────────
AUR_PACKAGES=(
  niri
)

install_packages() {
  info "Pacman paketleri kuruluyor..."
  sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}" \
    || warn "Bazı pacman paketleri kurulamadı, devam ediliyor..."
  success "Pacman paketleri tamamlandı."

  info "AUR paketleri kuruluyor (yay)..."
  yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" \
    || warn "Bazı AUR paketleri kurulamadı, devam ediliyor..."
  success "AUR paketleri tamamlandı."
}

# ── NetworkManager etkinleştirme ─────────────────────────────
enable_services() {
  info "Servisler etkinleştiriliyor..."
  sudo systemctl enable --now NetworkManager \
    && success "NetworkManager etkinleştirildi." \
    || warn "NetworkManager etkinleştirilemedi."
}

# ── Dotfiles kopyalama ───────────────────────────────────────
REPO_URL="https://github.com/lionesslie/niri-dotfiles"
REPO_DIR="$HOME/.cache/niri-dotfiles-install"
CONFIG_DIR="$HOME/.config"

clone_repo() {
  info "Dotfiles reposu klonlanıyor..."
  if [[ -d "$REPO_DIR" ]]; then
    warn "Eski klon bulundu, siliniyor..."
    rm -rf "$REPO_DIR"
  fi
  git clone --depth=1 "$REPO_URL" "$REPO_DIR"
  success "Repo klonlandı: $REPO_DIR"
}

backup_existing() {
  local target="$CONFIG_DIR/$1"
  if [[ -e "$target" ]]; then
    local backup="${target}.bak-$(date +%Y%m%d%H%M%S)"
    warn "Mevcut yapılandırma yedekleniyor: $target → $backup"
    mv "$target" "$backup"
  fi
}

copy_dotfiles() {
  info "Dotfiles ~/.config dizinine kopyalanıyor..."
  mkdir -p "$CONFIG_DIR"

  # Repo yapısını tespit et: dosyalar $REPO_DIR/.config/ altında mı,
  # yoksa doğrudan repo kökünde mi?
  local source_dir="$REPO_DIR"
  if [[ -d "$REPO_DIR/.config" ]]; then
    source_dir="$REPO_DIR/.config"
    info "Kaynak dizin: $source_dir (.config yapısı tespit edildi)"
  fi

  shopt -s dotglob nullglob

  # Repodaki her klasörü ~/.config altına kopyala
  for item in "$source_dir"/*/; do
    local name
    name=$(basename "$item")
    [[ "$name" == ".git" ]] && continue
    backup_existing "$name"
    cp -r "$item" "$CONFIG_DIR/$name"
    success "  ✔ $name → ~/.config/$name"
  done

  # Kök dizindeki loose dosyaları da kopyala (varsa)
  for item in "$source_dir"/*; do
    local name
    name=$(basename "$item")
    [[ -d "$item" ]] && continue               # Klasörler yukarıda işlendi
    [[ "$name" == README* ]] && continue       # README atla
    [[ "$name" == *.md ]] && continue          # .md dosyaları atla
    [[ "$name" == "install.sh" ]] && continue  # Kendini atla
    [[ "$name" == .git* ]] && continue
    [[ "$name" == LICENSE* ]] && continue
    backup_existing "$name"
    cp "$item" "$CONFIG_DIR/$name"
    success "  ✔ $name → ~/.config/$name"
  done

  shopt -u dotglob nullglob
}

# ── Fish'i varsayılan shell yap (opsiyonel) ──────────────────
set_fish_shell() {
  echo ""
  read -rp "$(echo -e "${YELLOW}Fish shell varsayılan shell olarak ayarlansın mı? [e/H]: ${RESET}")" answer
  if [[ "$answer" =~ ^[Ee]$ ]]; then
    local fish_path
    fish_path=$(command -v fish)
    if ! grep -qF "$fish_path" /etc/shells; then
      echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
    fi
    chsh -s "$fish_path"
    success "Varsayılan shell Fish olarak ayarlandı: $fish_path"
  else
    info "Shell değiştirilmedi."
  fi
}

# ── Temizlik ─────────────────────────────────────────────────
cleanup() {
  info "Geçici dosyalar temizleniyor..."
  rm -rf "$REPO_DIR"
  success "Temizlik tamamlandı."
}

# ── Özet ────────────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
  echo -e "${GREEN}${BOLD}║        Kurulum başarıyla tamamlandı! 🎉          ║${RESET}"
  echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
  echo ""
  echo -e "  ${BOLD}Sonraki adımlar:${RESET}"
  echo -e "  ${CYAN}1.${RESET} Sistemi yeniden başlatın veya niri oturumunu başlatın."
  echo -e "  ${CYAN}2.${RESET} ~/.config içindeki yapılandırmaları kendi ihtiyaçlarınıza göre düzenleyin."
  echo -e "  ${CYAN}3.${RESET} Sorun yaşarsanız: ${YELLOW}https://github.com/lionesslie/niri-dotfiles/issues${RESET}"
  echo ""
}

# ── Ana akış ─────────────────────────────────────────────────
main() {
  banner
  check_arch
  check_sudo
  install_prerequisites
  install_packages
  enable_services
  clone_repo
  copy_dotfiles
  set_fish_shell
  cleanup
  print_summary
}

main "$@"
