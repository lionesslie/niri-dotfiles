<div align="center">

# 🌸 niri-dotfiles

**lionesslie** tarafından hazırlanmış Arch Linux + Niri dotfiles koleksiyonu

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Niri](https://img.shields.io/badge/Niri-WM-blueviolet?style=for-the-badge)
![Wayland](https://img.shields.io/badge/Wayland-FFB800?style=for-the-badge&logo=wayland&logoColor=black)
![Fish](https://img.shields.io/badge/Fish_Shell-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Minimal, hızlı ve göze hitap eden bir **scrollable tiling** masaüstü deneyimi.

[Kurulum](#-kurulum) •
[İçerik](#-i̇çerik) •
[Kısayollar](#-klavye-kısayolları) •
[Yapı](#-dosya-yapısı) •
[Sorun Bildir](https://github.com/lionesslie/niri-dotfiles/issues)

</div>

---

## 📸 Ekran Görüntüleri

> Buraya masaüstünün ekran görüntülerini ekleyebilirsin.

<div align="center">
  <img src="assets/screenshot-1.png" width="80%" alt="Masaüstü Görünümü">
</div>

---

## 📦 İçerik

| Araç | Açıklama |
|------|----------|
| 🌸 **niri** | Scrollable tiling Wayland compositor |
| 📊 **waybar** | Durum çubuğu |
| 💻 **alacritty** | GPU hızlandırmalı terminal emülatörü |
| 🐟 **fish** | Kullanıcı dostu shell |
| 🚀 **rofi** | Uygulama başlatıcı |
| 📁 **thunar** | Dosya yöneticisi |
| ✏️ **neovim** | Metin editörü |
| 🌐 **firefox** | Web tarayıcısı |
| 🎮 **steam + gamemode** | Oyun performans desteği |
| 🖼️ **flameshot** | Ekran görüntüsü aracı |
| 💾 **udiskie / udisks2** | Otomatik disk bağlama |
| 🎨 **papirus-icon-theme** | İkon teması |
| 🔤 **JetBrains Mono Nerd Font** | Nerd Font desteği |

---

## ✨ Özellikler

- 🖱️ **Scrollable tiling** iş akışı — sonsuz yatay kolon düzeni
- ⌨️ Vim benzeri (`hjkl`) klavye navigasyonu
- 🎨 Özelleştirilmiş kenarlık, gölge ve gap ayarları
- 🔊 `wpctl` ile ses kontrolü, `playerctl` ile medya kontrolü
- 💡 `brightnessctl` ile ekran parlaklığı ayarı
- 🖥️ Çoklu monitör desteği
- 🎮 Steam ve GameMode entegrasyonu
- 🔒 Ekran kilidi (Swaylock) desteği

---

## 📋 Gereksinimler

- Arch Linux (veya türevi: EndeavourOS, Manjaro vb.)
- `sudo` yetkisine sahip bir kullanıcı
- İnternet bağlantısı
- (Opsiyonel) AUR erişimi için `yay`

> ⚠️ Bu dotfiles **yalnızca Arch tabanlı dağıtımlar** için test edilmiştir.

---

## 🚀 Kurulum

### Otomatik Kurulum (Önerilen)

```bash
git clone https://github.com/lionesslie/niri-dotfiles.git
cd niri-dotfiles
chmod +x install.sh
./install.sh
