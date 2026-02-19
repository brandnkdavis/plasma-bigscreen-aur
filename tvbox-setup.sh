#!/bin/bash

# v3: A script to create a full TV box appliance.
# - Installs prerequisites (yay, sddm).
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

# Prompt for the sudo password at the beginning.
sudo -v
echo "-> Sudo credentials verified."

# 1. Check for and install 'yay'
if ! command -v yay &> /dev/null; then
    echo "!! 'yay' not found. Installing now..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    echo "'yay' has been installed."
else
    echo "-> 'yay' is already installed."
fi

# 2. Check for and install 'sddm'
if ! pacman -Q sddm &> /dev/null; then
    echo "!! 'sddm' not found. Installing and enabling now..."
    sudo pacman -S --noconfirm sddm
    sudo systemctl enable sddm
    echo "'sddm' has been installed and enabled."
else
    echo "-> 'sddm' is already installed."
fi

# 3. Create user and configure SDDM autologin
echo "-> Checking for user '$AUTOLOGIN_USER' and configuring autologin..."

# Check if the user exists; if not, create it.
if ! id -u "$AUTOLOGIN_USER" &>/dev/null; then
    echo "!! User '$AUTOLOGIN_USER' not found. Creating user..."
    # Create the user with a home directory and add to important groups for media playback.
    sudo useradd -m -g users -G wheel,audio,video,storage,power,network "$AUTOLOGIN_USER"
    echo "-> User '$AUTOLOGIN_USER' created. NOTE: The user has no password by default."
    echo "-> For optional security, you can set one later with 'sudo passwd $AUTOLOGIN_USER'"
else
    echo "-> User '$AUTOLOGIN_USER' already exists."
fi

# Create the SDDM autologin configuration file.
AUTOLOGIN_CONF_DIR="/etc/sddm.conf.d"
AUTOLOGIN_CONF_FILE="$AUTOLOGIN_CONF_DIR/autologin.conf"
echo "-> Creating SDDM autologin configuration at $AUTOLOGIN_CONF_FILE"
sudo mkdir -p "$AUTOLOGIN_CONF_DIR"
# Use a "here document" with sudo tee to write the protected file.
sudo tee "$AUTOLOGIN_CONF_FILE" > /dev/null <<EOT
[Autologin]
User=$AUTOLOGIN_USER
Session=plasma-bigscreen.desktop
EOT
echo "Autologin configured for user '$AUTOLOGIN_USER' with the Plasma Bigscreen session."


echo "-> Prerequisite check and setup complete."

# --- MAIN BUILD PROCESS ---

cleanup() {
    if [ -d "$TMP_DIR" ]; then
        echo "---"; echo "-> Cleaning up temporary build directory..."; rm -rf "$TMP_DIR"; echo "-> Cleanup complete.";
    fi
}
TMP_DIR=$(mktemp -d); trap cleanup EXIT; cd "$TMP_DIR"
PKGBUILD_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main/PKGBUILD"

echo "---"; echo "-> Downloading PKGBUILD from: $PKGBUILD_URL"
curl -L -o PKGBUILD "$PKGBUILD_URL"
if [ ! -f "PKGBUILD" ]; then echo "!! ERROR: Failed to download PKGBUILD."; exit 1; fi

echo "-> Using 'yay' to install all dependencies from the PKGBUILD..."
source PKGBUILD
yay -S --noconfirm --needed "${depends[@]}" "${makedepends[@]}"

echo "---"; echo "-> Dependencies satisfied. Starting the final build with makepkg."
makepkg -i --noconfirm --clean

echo "---"
echo "✅ SUCCESS! Your TV box setup is complete."
echo "-> Reboot your system now. It will automatically log in to the 'tvbox' user and start Plasma Bigscreen."

