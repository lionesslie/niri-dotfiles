#!/usr/bin/env bash
#
# copy-nix.sh
#
# NixOS kullanıcıları için: installer.sh (Arch/AUR paket kurulumu yapan
# betik) bu sistemde işe yaramadığından, bu betik SADECE bu repodaki
# config klasörlerini ~/.config altına kopyalar. Paket kurulumu
# configuration.nix (environment.systemPackages) üzerinden `nixos-rebuild
# switch` ile yapılır.
#
# Kullanım:
#   chmod +x copy-nix.sh
#   ./copy-nix.sh
#
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
  "hardware-configuration.nix"
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

echo "✅ Tamamlandı: $copied klasör ~/.config içine kopyalandı."
echo "   Bir şey bozulursa *.bak-${TIMESTAMP} yedeklerinden geri dönebilirsin."
