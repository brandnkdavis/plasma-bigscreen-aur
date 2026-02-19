#!/bin/bash

# v4: A script to create a full TV box appliance.
# - Installs prerequisites (yay, sddm, flatpak).
# - Adds the Flathub remote for Flatpak.
# - Creates a dedicated user ('tvbox').
# - Configures autologin for that user into the Bigscreen session.
# - Builds and installs plasma-bigscreen-git from a GitHub repository.

# --- START CONFIGURATION ---
# Replace this with your GitHub username and repository name.
GITHUB_USER="brandnkdavis"
GITHUB_REPO="plasma-bigscreen-aur"
# The dedicated user to create and autologin as.
AUTOLOGIN_USER="tvbox"
# --- END CONFIGURATION ---

# Exit immediately if a command exits with a non-zero status.
set -e

# --- PRE-FLIGHT CHECKS & PREREQUISITE INSTALLATION ---

echo "---"
echo "-> Starting prerequisite check and system setup..."

sudo -v
echo "-> Sudo credentials verified."

# 1. Install 'yay'
if ! command -v yay &> /dev/null; then
    echo "!! 'yay' not found. Installing now..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    echo "✅ 'yay' has been installed."
else
    echo "-> 'yay' is already installed."
fi

# 2. Install 'sddm'
if ! pacman -Q sddm &> /dev/null; then
    echo "!! 'sddm' not found. Installing and enabling now..."
    sudo pacman -S --noconfirm sddm
    sudo systemctl enable sddm
    echo "✅ 'sddm' has been installed and enabled."
else
    echo "-> 'sddm' is already installed."
fi

# 3. Install and Configure Flatpak
if ! command -v flatpak &> /dev/null; then
    echo "!! 'flatpak' not found. Installing and configuring now..."
    sudo pacman -S --noconfirm flatpak
    # Add the main Flathub repository system-wide so the user can access it
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo "✅ 'flatpak' has been installed and Flathub repository configured."
else
    echo "-> 'flatpak' is already installed."
fi

# 4. Create user and configure SDDM autologin
echo "-> Checking for user '$AUTOLOGIN_USER' and configuring autologin..."
if ! id -u "$AUTOLOGIN_USER" &>/dev/null; then
    echo "!! User '$AUTOLOGIN_USER' not found. Creating passwordless user..."
    sudo useradd -m -g users -G wheel,audio,video,storage,power,network "$AUTOLOGIN_USER"
    echo "✅ User '$AUTOLOGIN_USER' created without a password for seamless login."
else
    echo "-> User '$AUTOLOGIN_USER' already exists."
fi

AUTOLOGIN_CONF_DIR="/etc/sddm.conf.d"
AUTOLOGIN_CONF_FILE="$AUTOLOGIN_CONF_DIR/autologin.conf"
echo "-> Creating SDDM autologin configuration..."
sudo mkdir -p "$AUTOLOGIN_CONF_DIR"
sudo tee "$AUTOLOGIN_CONF_FILE" > /dev/null <<EOT
[Autologin]
User=$AUTOLOGIN_USER
Session=plasma-bigscreen.desktop
EOT
echo "✅ Autologin configured."

echo "-> Prerequisite check and setup complete."

# --- MAIN BUILD PROCESS ---

cleanup() { if [ -d "$TMP_DIR" ]; then echo "---"; echo "-> Cleaning..."; rm -rf "$TMP_DIR"; fi; }
TMP_DIR=$(mktemp -d); trap cleanup EXIT; cd "$TMP_DIR"
PKGBUILD_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main/PKGBUILD"
echo "---"; echo "-> Downloading PKGBUILD..."
curl -L -o PKGBUILD "$PKGBUILD_URL"
if [ ! -f "PKGBUILD" ]; then echo "!! ERROR: Failed to download PKGBUILD."; exit 1; fi
source PKGBUILD
echo "-> Installing dependencies with 'yay'..."
yay -S --noconfirm --needed "${depends[@]}" "${makedepends[@]}"
echo "---"; echo "-> Building main package with 'makepkg'..."
makepkg -i --noconfirm --clean

echo "---"
echo "✅ SUCCESS! Your TV box setup is complete."
echo "-> Reboot your system now for a seamless, passwordless experience."
