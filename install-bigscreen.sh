#!/bin/bash

# v2: A script to install prerequisites (yay, sddm) and then build/install 
# plasma-bigscreen-git from a GitHub repository.

# --- START CONFIGURATION ---
# Replace this with your GitHub username and repository name.
GITHUB_USER="brandnkdavis"
GITHUB_REPO="plasma-bigscreen-aur"
# --- END CONFIGURATION ---

# Exit immediately if a command exits with a non-zero status.
set -e

# --- PRE-FLIGHT CHECKS & PREREQUISITE INSTALLATION ---

echo "---"
echo "-> Starting prerequisite check..."

# Prompt for the sudo password at the beginning so it doesn't interrupt later steps.
sudo -v
echo "-> Sudo credentials verified."

# 1. Check for and install 'yay' if not present
if ! command -v yay &> /dev/null; then
    echo "!! 'yay' not found. Installing now..."
    # Install base-devel and git, which are required to build AUR packages
    sudo pacman -S --noconfirm --needed base-devel git
    
    # Clone, build, and install yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    
    echo "'yay' has been installed."
else
    echo "-> 'yay' is already installed. Skipping."
fi

# 2. Check for and install 'sddm' if not present
if ! pacman -Q sddm &> /dev/null; then
    echo "!! 'sddm' not found. Installing and enabling now..."
    sudo pacman -S --noconfirm sddm
    sudo systemctl enable sddm
    echo "'sddm' has been installed and enabled as the default display manager."
else
    echo "-> 'sddm' is already installed. Skipping."
fi

echo "-> Prerequisite check complete."

# --- MAIN BUILD PROCESS ---

# Function for cleanup, to be called on script exit
cleanup() {
    if [ -d "$TMP_DIR" ]; then
        echo "---"
        echo "-> Cleaning up temporary build directory..."
        rm -rf "$TMP_DIR"
        echo "-> Cleanup complete."
    fi
}

# Create a temporary directory to work in
TMP_DIR=$(mktemp -d)
trap cleanup EXIT

echo "---"
echo "-> Created temporary directory at: $TMP_DIR"
cd "$TMP_DIR"

# Construct the URL to the raw PKGBUILD file on GitHub
PKGBUILD_URL="https://raw.githubusercontent.com/brandnkdavis/plasma-bigscreen-aur/main/PKGBUILD"

echo "-> Downloading PKGBUILD from: $PKGBUILD_URL"
curl -L -o PKGBUILD "$PKGBUILD_URL"

# Verify that the download was successful
if [ ! -f "PKGBUILD" ]; then
    echo "!! ERROR: Failed to download PKGBUILD. Please check the URL and your connection."
    exit 1
fi

echo "-> PKGBUILD downloaded successfully."
echo "---"
echo "-> Using 'yay' to install all dependencies from the PKGBUILD..."

# Source the PKGBUILD to get the dependency arrays
source PKGBUILD
# Use yay to install both official and AUR dependencies
yay -S --noconfirm --needed "${depends[@]}" "${makedepends[@]}"

echo "---"
echo "-> Dependencies are satisfied. Starting the final build with makepkg."
echo "-> You may be prompted for your password again to install the final package."

# Run makepkg to build and install the package. 
# We no longer need -s because 'yay' already handled the dependencies.
makepkg -i --noconfirm --clean

echo "---"
echo "SUCCESS: Plasma Bigscreen has been built and installed."
echo "-> You can now reboot your system. At the login screen, choose the 'Plasma Bigscreen' session."

