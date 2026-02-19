#!/bin/bash

# A script to download and install the plasma-bigscreen-git package from a GitHub repo.
# It handles temporary directories and cleanup automatically.

# --- START CONFIGURATION ---
# Replace this with your GitHub username and repository name.
GITHUB_USER="your-username"
GITHUB_REPO="plasma-bigscreen-aur"
# --- END CONFIGURATION ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Function for cleanup, to be called on script exit
cleanup() {
    echo "---"
    echo "-> Cleaning up temporary directory..."
    rm -rf "$TMP_DIR"
    echo "-> Cleanup complete."
}

# Create a temporary directory to work in
# The `trap` command ensures the cleanup function is called when the script exits,
# for any reason (success, failure, or interruption).
TMP_DIR=$(mktemp -d)
trap cleanup EXIT

echo "-> Created temporary directory at: $TMP_DIR"
cd "$TMP_DIR"

# Construct the URL to the raw PKGBUILD file on GitHub
PKGBUILD_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main/PKGBUILD"

echo "-> Downloading PKGBUILD from: $PKGBUILD_URL"
curl -L -o PKGBUILD "$PKGBUILD_URL"

# Verify that the download was successful and the PKGBUILD exists
if [ ! -f "PKGBUILD" ]; then
    echo "!! ERROR: Failed to download PKGBUILD. Please check the URL and your connection."
    exit 1
fi

echo "-> PKGBUILD downloaded successfully."
echo "---"
echo "-> Starting the build process with makepkg. This may take a while."
echo "-> You will be prompted for your password to install dependencies and the final package."

# Run makepkg
# -s : Sync and install dependencies automatically using pacman.
# -i : Install the package after a successful build.
# -c : Clean up leftover files and directories after the build.
makepkg -sic

echo "---"
echo "✅ SUCCESS: The package has been built and installed."

