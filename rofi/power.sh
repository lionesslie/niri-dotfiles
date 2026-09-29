#!/usr/bin/env bash
choice=$(printf "󰐥  Kapat\n󰜉  Yeniden Başlat\n󰍃  Çıkış Yap" | rofi -dmenu -i -p "" \
  -theme-str 'window {width: 260px;} listview {lines: 3;} inputbar {enabled: false;}')

case "$choice" in
  *Kapat)   systemctl poweroff ;;
  *Yeniden*) systemctl reboot ;;
  *Çıkış*)  niri msg action quit --skip-confirmation ;;
esac