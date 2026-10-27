#!/usr/bin/env bash
# ==============================================================================
# QUATTRO-VOID DOTFILES ONE-SHOT INSTALLER FOR VOID LINUX
# Target User: rajan (/home/rajan)
# Pure Quickshell Architecture: Zero Rofi, Zero Walker, Zero Waybar, Zero Mako,
# Zero SwayOSD, Zero Swaybg. Single-process Quickshell desktop + TUI utilities.
# ==============================================================================

set -euo pipefail

TARGET_USER="${SUDO_USER:-rajan}"
TARGET_HOME="/home/${TARGET_USER}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_ok()    { printf "${GREEN}[OK]${NC}   %s\n" "$1"; }
log_warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }

echo "======================================================================"
echo "  Quattro-Void Pure Quickshell + Hyprland Setup for Void (${TARGET_USER})"
echo "======================================================================"

# 1. Configure Void Linux Community Hyprland XBPS Repository
setup_void_repos() {
    log_info "Checking Void Linux XBPS repositories for Hyprland & Quickshell..."
    sudo mkdir -p /etc/xbps.d
    if [ ! -f /etc/xbps.d/hyprland-void.conf ]; then
        log_info "Adding void-land/hyprland-void-packages repository to /etc/xbps.d/hyprland-void.conf..."
        echo "repository=https://github.com/void-land/hyprland-void-packages/releases/latest/download/" | sudo tee /etc/xbps.d/hyprland-void.conf >/dev/null
    fi
    sudo xbps-install -Suy xbps || true
    sudo xbps-install -Sy
}

# 2. Install Core Packages via XBPS (Strictly No Rofi, No Mako, No Waybar, No GNOME bloat)
install_packages() {
    log_info "Installing Wayland, Quickshell, PipeWire, Networking, TUI, and CLI packages..."

    CORE_PKGS=(
        # Session, Seat, DBus & Portals
        dbus elogind seatd polkit
        wayland wayland-protocols xorg-server-xwayland
        xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
        mesa-dri vulkan-loader

        # Audio (PipeWire + WirePlumber + TUI Mixers)
        pipewire wireplumber alsa-pipewire libspa-bluetooth
        pulsemixer alsa-utils playerctl

        # Networking & Bluetooth
        NetworkManager bluez

        # Pure Quickshell & Wayland Utilities (No rofi, no mako, no waybar, no swayosd)
        foot alacritty
        wl-clipboard cliphist
        grim slurp wlsunset brightnessctl
        qt6-wayland qt6-declarative qt6-svg qt6-shadertools qt6ct
        python3

        # Daily CLI & TUI Power Tools
        zsh starship fzf zoxide eza bat fd ripgrep jq
        btop yazi lazygit calcurse neovim fastfetch git curl unzip

        # Fonts
        nerd-fonts-symbols-ttf font-jetbrains-mono-ttf noto-fonts-ttf noto-fonts-emoji
    )

    for pkg in "${CORE_PKGS[@]}"; do
        if ! sudo xbps-install -y "$pkg" 2>/dev/null; then
            log_warn "Optional or renamed package '$pkg' skipped."
        fi
    done

    log_info "Installing Hyprland, Quickshell, & TUI hardware packages..."
    HYPR_PKGS=(hyprland hyprpicker xdg-desktop-portal-hyprland quickshell wiremix impala bluetuith)
    for hpkg in "${HYPR_PKGS[@]}"; do
        if ! sudo xbps-install -y "$hpkg" 2>/dev/null; then
            log_warn "Package '$hpkg' not found in active binary mirror; see README.md for xbps-src / cargo build."
        fi
    done

    log_ok "Package installation complete."
}

# 3. Configure Runit Services & User Groups for `rajan`
setup_runit_and_groups() {
    log_info "Configuring user groups for '${TARGET_USER}'..."
    for grp in wheel video audio input _seatd bluetooth network storage; do
        if getent group "$grp" >/dev/null 2>&1; then
            sudo usermod -aG "$grp" "$TARGET_USER" || true
        fi
    done

    log_info "Enabling Void Linux runit services in /var/service..."
    for conflict_svc in wpa_supplicant dhcpcd; do
        if [ -L "/var/service/${conflict_svc}" ]; then
            log_warn "Removing conflicting service /var/service/${conflict_svc} in favor of NetworkManager..."
            sudo rm -f "/var/service/${conflict_svc}"
        fi
    done

    for svc in dbus elogind seatd NetworkManager bluetoothd polkitd; do
        if [ -d "/etc/sv/${svc}" ] && [ ! -L "/var/service/${svc}" ]; then
            sudo ln -sf "/etc/sv/${svc}" "/var/service/${svc}"
            log_ok "Enabled runit service: ${svc}"
        fi
    done

    sudo mkdir -p /etc/alsa/conf.d
    [ -f /usr/share/alsa/alsa.conf.d/50-pipewire.conf ] && sudo ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/
    [ -f /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf ] && sudo ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
}

# 4. Deploy Dotfiles to /home/rajan
deploy_dotfiles() {
    log_info "Deploying Quattro-Void pure Quickshell dotfiles to ${TARGET_HOME}..."
    BACKUP_DIR="${TARGET_HOME}/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "${TARGET_HOME}/.config" "${TARGET_HOME}/.local/bin" "${TARGET_HOME}/.local/state/quattro/current" "${TARGET_HOME}/Pictures/Screenshots"

    for dir in hypr quickshell themes foot alacritty btop yazi lazygit fastfetch; do
        if [ -e "${TARGET_HOME}/.config/${dir}" ]; then
            mkdir -p "$BACKUP_DIR"
            cp -r "${TARGET_HOME}/.config/${dir}" "$BACKUP_DIR/"
        fi
        rm -rf "${TARGET_HOME}/.config/${dir}"
        cp -r "${REPO_DIR}/config/${dir}" "${TARGET_HOME}/.config/${dir}"
    done

    cp "${REPO_DIR}/config/starship.toml" "${TARGET_HOME}/.config/starship.toml"
    cp -f "${REPO_DIR}/local/bin/"* "${TARGET_HOME}/.local/bin/"
    chmod +x "${TARGET_HOME}/.local/bin/"*

    cp "${REPO_DIR}/zsh/.zshrc" "${TARGET_HOME}/.zshrc"
    cp "${REPO_DIR}/zsh/.zprofile" "${TARGET_HOME}/.zprofile"

    echo "tokyo-night" > "${TARGET_HOME}/.local/state/quattro/current/theme.name"

    if command -v zsh >/dev/null 2>&1; then
        sudo chsh -s "$(command -v zsh)" "$TARGET_USER" || true
    fi

    sudo chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.config" "${TARGET_HOME}/.local" "${TARGET_HOME}/.zshrc" "${TARGET_HOME}/.zprofile" 2>/dev/null || true
    log_ok "Dotfiles deployed to ${TARGET_HOME}."
}

setup_void_repos
install_packages
setup_runit_and_groups
deploy_dotfiles

echo ""
echo "======================================================================"
log_ok "Quattro-Void pure Quickshell setup finished! Log in on TTY1 as '${TARGET_USER}'."
echo "======================================================================"
