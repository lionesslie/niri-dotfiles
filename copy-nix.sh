#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TARGET_DIR="${HOME}/.config"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# Kopyalanmaması gereken dosya/klasörler (config değil, repo meta dosyaları)
EXCLUDE=(
  "README.md"
  "installer.sh"
  "copy-nix.sh"
  "configuration.nix"
  "assets"
  "LICENSE"
  ".git"
  ".github"
  ".gitignore"
)

is_excluded() {
  local name="$1"
  for e in "${EXCLUDE[@]}"; do
    if [[ "$name" == "$e" ]]; then
      return 0
    fi
  done
  return 1
}

# ---------- 1) config klasörleri -> ~/.config ----------
mkdir -p "$TARGET_DIR"

echo "==> Kaynak dizin : $REPO_DIR"
echo "==> Hedef dizin  : $TARGET_DIR"
echo

shopt -s nullglob dotglob
copied=0

for entry in "$REPO_DIR"/*; do
  name="$(basename "$entry")"

  if is_excluded "$name"; then
    continue
  fi

  # Sadece klasörleri (config dizinlerini) kopyala
  if [ ! -d "$entry" ]; then
    continue
  fi

  dest="$TARGET_DIR/$name"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="${dest}.bak-${TIMESTAMP}"
    echo "  ! Mevcut config bulundu, yedekleniyor:"
    echo "      $dest"
    echo "      -> $backup"
    mv "$dest" "$backup"
  fi

  echo "  -> Kopyalanıyor: $name/  ~/.config/$name"
  cp -r "$entry" "$dest"
  copied=$((copied + 1))
done

shopt -u nullglob dotglob

echo
if [ "$copied" -eq 0 ]; then
  echo "⚠️  Kopyalanacak klasör bulunamadı. Betiği repo kök dizininde çalıştırdığından emin ol."
  exit 1
fi

echo "✅ $copied klasör ~/.config içine kopyalandı."
echo

# ---------- 2) configuration.nix -> /etc/nixos ----------
NIX_SRC="$REPO_DIR/configuration.nix"
NIX_DEST="/etc/nixos/configuration.nix"

if [ -f "$NIX_SRC" ]; then
  SUDO=""
  if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
  fi

  if [ -e "$NIX_DEST" ]; then
    NIX_BACKUP="${NIX_DEST}.bak-${TIMESTAMP}"
    echo "  ! Mevcut configuration.nix yedekleniyor:"
    echo "      $NIX_DEST"
    echo "      -> $NIX_BACKUP"
    $SUDO cp -a "$NIX_DEST" "$NIX_BACKUP"
  fi

  echo "  -> Kopyalanıyor: configuration.nix  /etc/nixos/"
  $SUDO cp "$NIX_SRC" "$NIX_DEST"
  echo "✅ configuration.nix kopyalandı."
  echo "   Uygulamak için: sudo nixos-rebuild switch"
else
  echo "  ! Repoda configuration.nix bulunamadı, /etc/nixos atlandı."
fi

echo
echo "Bir şey bozulursa *.bak-${TIMESTAMP} yedeklerinden geri dönebilirsin."
