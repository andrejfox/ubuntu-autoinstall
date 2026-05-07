#!/usr/bin/env bash

set -e

APP_ID="com.nextcloud.desktopclient.nextcloud"
AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/nextcloud-flatpak.desktop"

echo "=== Nextcloud Flatpak Installer ==="

# -----------------------------
# Install Flatpak if missing
# -----------------------------
if ! command -v flatpak >/dev/null 2>&1; then
    echo "Flatpak not found. Installing..."

    if command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y flatpak

    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y flatpak

    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm flatpak

    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y flatpak

    else
        echo "Unsupported package manager."
        exit 1
    fi
else
    echo "Flatpak already installed."
fi

# -----------------------------
# Add Flathub repo if missing
# -----------------------------
if ! flatpak remote-list | grep -q '^flathub$'; then
    echo "Adding Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub \
        https://flathub.org/repo/flathub.flatpakrepo
else
    echo "Flathub repository already exists."
fi

# -----------------------------
# Install Nextcloud if missing
# -----------------------------
if flatpak info "$APP_ID" >/dev/null 2>&1; then
    echo "Nextcloud already installed."
else
    echo "Installing Nextcloud..."
    flatpak install -y flathub "$APP_ID"
fi


# -----------------------------
# Launch only if not running
# -----------------------------
if pgrep -f "$APP_ID" >/dev/null 2>&1; then
    echo "Nextcloud is already running."
else
    echo "Launching Nextcloud..."
    nohup flatpak run "$APP_ID" >/dev/null 2>&1 &
fi

echo "=== Done ==="
echo "Nextcloud is installed, configured to autostart, and ready for sync."
