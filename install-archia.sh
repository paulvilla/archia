#!/bin/bash

# --- 1. Repositorios y CachyOS ---
sudo pacman-key --recv-keys F3B607488DB3A048
sudo pacman-key --lsign-key F3B607488DB3A048
sudo pacman -U 'https://mirror.cachyos.org/cachyos/x86_64/cachyos-keyring-20240331-1-any.pkg.tar.zst'
sudo pacman -U 'https://mirror.cachyos.org/cachyos/x86_64/cachyos-mirrorlist-1-1-any.pkg.tar.zst'

sudo bash -c 'cat <<EOF > /etc/pacman.conf
[options]
HoldPkg = pacman glibc
Architecture = auto
CheckSpace

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF'

# --- 2. Instalación de paquetes ---
sudo pacman -Syu --noconfirm base-devel sddm limine ccache nautilus networkmanager pipewire pipewire-pulse wireplumber polkit-gnome gnome-keyring papirus-icon-theme niri xwayland-satellite brave-bin ghostty

# --- 3. Instalación de gestores AUR ---
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd .. && rm -rf paru

# Configuración Paru
sudo bash -c 'cat <<EOF >> /etc/paru.conf
[options]
BottomUp
SudoLoop
EOF'

# --- 4. Instalación de Noctalia y Pkgtop-up ---
paru -S --noconfirm noctalia-shell-git pkgtop-up

# --- 5. Configuración Automática de Entorno ---
# Crear directorios de configuración
mkdir -p ~/.config/niri
mkdir -p ~/.config/gtk-3.0

# Configurar GTK para usar Papirus
echo "[Settings]" > ~/.config/gtk-3.0/settings.ini
echo "gtk-icon-theme-name=Papirus-Dark" >> ~/.config/gtk-3.0/settings.ini

# Autoinicio de Noctalia dentro de Niri
# Esto crea un archivo de configuración base para Niri que lanza Noctalia
cat <<EOF > ~/.config/niri/config.kdl
spawn-at-startup "noctalia"
prefer-no-csd
EOF

# --- 6. Servicios ---
sudo systemctl enable sddm
sudo systemctl enable NetworkManager

echo "Instalación completada con éxito."
echo "IMPORTANTE: Tras reiniciar, si usas una tarjeta NVIDIA,"
echo "deberás instalar los drivers (nvidia-cachyos) desde el repo de CachyOS."