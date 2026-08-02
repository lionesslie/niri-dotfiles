<div align="center">

# 🌸 niri-dotfiles

**lionesslie**'s Arch Linux + Niri dotfiles collection

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Niri](https://img.shields.io/badge/Niri-WM-blueviolet?style=for-the-badge)
![Wayland](https://img.shields.io/badge/Wayland-FFB800?style=for-the-badge&logo=wayland&logoColor=black)
![Fish](https://img.shields.io/badge/Fish_Shell-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A minimal, fast, and visually appealing **scrollable tiling** desktop experience.

[Installation](#-installation) •
[Contents](#-contents) •
[Shortcuts](#-keyboard-shortcuts) •
[Structure](#-file-structure) •
[Report an Issue](https://github.com/lionesslie/niri-dotfiles/issues)

</div>

---

## 📸 Screenshots

> You can add screenshots of your desktop here.

<div align="center">
  <img src="assets/screenshot-1.png" width="80%" alt="Desktop View">
</div>

---

## 📦 Contents

| Tool | Description |
|------|-------------|
| 🌸 **niri** | Scrollable tiling Wayland compositor |
| 📊 **asg** | Status bar |
| 💻 **alacritty** | GPU-accelerated terminal emulator |
| 🐟 **fish** | User-friendly shell |
| 🚀 **rofi** | Application launcher |
| 📁 **thunar** | File manager |
| ✏️ **neovim** | Text editor |
| 🌐 **firefox** | Web browser |
| 🎮 **steam + gamemode** | Gaming performance support |
| 🖼️ **flameshot** | Screenshot tool |
| 💾 **udiskie / udisks2** | Automatic disk mounting |
| 🎨 **papirus-icon-theme** | Icon theme |
| 🔤 **JetBrains Mono Nerd Font** | Nerd Font support |

---

## ✨ Features

- 🖱️ **Scrollable tiling** workflow — infinite horizontal column layout
- ⌨️ Vim-style (`hjkl`) keyboard navigation
- 🎨 Customized border, shadow, and gap settings
- 🔊 Volume control via `wpctl`, media control via `playerctl`
- 💡 Screen brightness adjustment via `brightnessctl`
- 🖥️ Multi-monitor support
- 🎮 Steam and GameMode integration
- 🔒 Screen lock (Swaylock) support

---

## 📋 Requirements

- Arch Linux (or derivatives: EndeavourOS, Manjaro, etc.)
- A user with `sudo` privileges
- Internet connection
- (Optional) `yay` for AUR access

> ⚠️ These dotfiles have been tested **only on Arch-based distributions**.

---

## 🚀 Installation

### Automatic Installation (Recommended)

```bash
git clone https://github.com/lionesslie/niri-dotfiles.git
cd niri-dotfiles
chmod +x install.sh
./install.sh
