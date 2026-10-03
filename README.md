# Hyprland Dotfiles

My personal **Hyprland dotfiles** for an Arch Linux / Wayland setup.

Built around a minimal, customizable workflow with Hyprland, Waybar, Kitty, Wofi, Mako and Matugen.

> **Note:** These dotfiles are primarily made for my own setup. Some configurations may require additional packages or personal adjustments before they work on another system.

---

## ✨ Features

- 🪟 **Hyprland** — Dynamic tiling Wayland compositor
- 📊 **Waybar** — Status bar and system information
- 🖥️ **Kitty** — Terminal emulator
- 🔔 **Mako** — Notification daemon
- 🚀 **Wofi** — Application launcher
- 🎨 **Matugen** — Dynamic color/theme generation
- 🛠️ **Custom scripts** — Small utilities for managing and interacting with the setup

---

## 📂 Structure

```text
hypr-dotfiles/
├── hypr/        # Hyprland configuration
├── kitty/       # Kitty terminal configuration
├── mako/        # Mako notification configuration
├── matugen/     # Matugen theme configuration
├── scripts/     # Custom utility scripts
├── waybar/      # Waybar configuration
├── wofi/        # Wofi launcher configuration
└── .gitignore
```

---

## 🛠️ Requirements

This setup is intended for a **Linux + Wayland** environment.

You'll need the applications used by the configurations, including:

- [Hyprland](https://hyprland.org/)
- [Waybar](https://github.com/Alexays/Waybar)
- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [Mako](https://github.com/emersion/mako)
- [Wofi](https://hg.sr.ht/~scoopta/wofi)
- [Matugen](https://github.com/InioX/matugen)

Additional dependencies may be required by individual scripts or configuration files.

---

## 📥 Installation

Clone the repository:

```bash
git clone https://github.com/0xmaxw08/hypr-dotfiles.git
cd hypr-dotfiles
```

Before applying the configurations, **back up your existing configuration files**.

You can then copy the required configurations into `~/.config/`.

For example:

```bash
cp -r hypr ~/.config/
cp -r kitty ~/.config/
cp -r mako ~/.config/
cp -r matugen ~/.config/
cp -r waybar ~/.config/
cp -r wofi ~/.config/
```

Copy the scripts as required by your setup.

> ⚠️ Review the configuration files before copying them if you're using a different system. Paths, monitors, keybinds and installed applications may need to be changed.

---

## 🎨 Theming

The setup uses **Matugen** for dynamic theming.

This allows the desktop configuration to use generated colors across supported components.

---

## ⌨️ Keybinds

Keybindings are configured through the Hyprland configuration.

See:

```text
hypr/
```

for the current bindings and other compositor settings.

---

## ⚠️ Disclaimer

These are my personal dotfiles and are **not intended to be a universal installation**.

Configurations may change over time and may depend on packages, paths, hardware or other settings specific to my system.

Feel free to take whatever you find useful and modify it for your own setup.

---

## 📄 License

Use, modify and adapt these configurations as you see fit.
