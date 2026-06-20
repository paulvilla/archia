#!/bin/bash

# --- 1. Preparar CachyOS usando su método oficial ---
echo "Descargando e instalando el repositorio de CachyOS..."
curl -L https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo
sudo ./cachyos-repo.sh
cd .. && rm -rf cachyos-repo*

# --- 2. Actualización y herramientas base ---
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
    base-devel sddm limine ccache \
    nautilus networkmanager \
    pipewire pipewire-pulse wireplumber \
    polkit-gnome gnome-keyring \
    papirus-icon-theme \
    niri xwayland-satellite \
    brave-bin ghostty

# --- 3. Instalación de Yay y Paru ---
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd .. && rm -rf paru

# Configuración de Paru para evitar preguntas innecesarias
sudo bash -c 'cat <<EOF >> /etc/paru.conf
[options]
BottomUp
SudoLoop
EOF'

# --- 4. Instalación de componentes adicionales (AUR) ---
paru -S --noconfirm noctalia-shell-git pkgtop-up

# --- 5. Configuración de Entorno ---
mkdir -p ~/.config/niri ~/.config/gtk-3.0

# Configurar iconos
echo -e "[Settings]\ngtk-icon-theme-name=Papirus-Dark" > ~/.config/gtk-3.0/settings.ini

# Configurar Niri para arrancar Noctalia
echo -e 'spawn-at-startup "noctalia"\nprefer-no-csd' > ~/.config/niri/config.kdl

# --- 6. Habilitar Servicios ---
sudo systemctl enable sddm
sudo systemctl enable NetworkManager

echo "--------------------------------------------------------"
echo "¡INSTALACIÓN COMPLETADA CON ÉXITO!"
echo "IMPORTANTE: Antes de reiniciar, instala Limine en tu disco:"
echo "sudo limine-install-uefi-x86_64 /dev/sdX"
echo "(Cambia /dev/sdX por tu disco real)"
echo "--------------------------------------------------------"