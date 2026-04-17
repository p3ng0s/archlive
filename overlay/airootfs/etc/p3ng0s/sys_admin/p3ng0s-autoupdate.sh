#!/bin/bash
# p3ng0s-autoupdate.sh
# Created on: Thu 16 Apr 2026 09:34:21 PM CEST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:

set -euo pipefail

LIVE_MODE=false
grep -q "airootfs" /proc/mounts && LIVE_MODE=true

if $LIVE_MODE; then
    echo "[*] Live ISO detected, skipping update, checking pending..."
    PENDING=$(pacman -Qu 2>/dev/null | wc -l)
    wall "$(printf '[monthly-update] %d package(s) pending update.' "$PENDING")"
    echo "[+] wall sent, exiting."
    exit 0
fi
# ─── CONFIG ───────────────────────────────────────────────────────────────────

TMUX_SESSION="update"
LOG_FILE="/var/log/monthly-update.log"

# Packages that warrant a special notification if updated
# Add your own to the CUSTOM list
KERNEL_PKGS=(linux linux-lts linux-hardened linux-zen)
BOOTLOADER_PKGS=(grub efibootmgr)
SECURITY_PKGS=(openssl openssh gnupg sudo)
NETWORK_PKGS=(openvpn wireguard-tools networkmanager wpa_supplicant)
CUSTOM_PKGS=() # <- Add your own here e.g. (metasploit nmap burpsuite)

IMPORTANT_PKGS=(
    "${KERNEL_PKGS[@]}"
    "${BOOTLOADER_PKGS[@]}"
    "${SECURITY_PKGS[@]}"
    "${NETWORK_PKGS[@]}"
    "${CUSTOM_PKGS[@]}"
)

# ─── DETECT USER ──────────────────────────────────────────────────────────────

REAL_USER=$(who | awk 'NR==1{print $1}')

if [ -z "$REAL_USER" ]; then
    echo "[!] No logged-in user detected, aborting." | tee -a "$LOG_FILE"
    exit 1
fi

REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
REAL_UID=$(id -u "$REAL_USER")
REAL_GID=$(id -g "$REAL_USER")

# Get X11 display and dbus for notify-send
DISPLAY_VAR=$(who | awk 'NR==1{print $5}' | tr -d '()')
[ -z "$DISPLAY_VAR" ] && DISPLAY_VAR=":0"

DBUS_ADDR=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u "$REAL_USER" -n)/environ 2>/dev/null | tr -d '\0' | sed 's/DBUS_SESSION_BUS_ADDRESS=//')

# Helper to run a command as the real user with X11/dbus env
run_as_user() {
    sudo -u "$REAL_USER" \
        DISPLAY="$DISPLAY_VAR" \
        DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" \
        HOME="$REAL_HOME" \
        "$@"
}

# Helper to send a desktop notification
notify() {
    local TITLE="$1"
    local MSG="$2"
    local URGENCY="${3:-normal}"
    run_as_user notify-send -i /etc/p3ng0s/icons/p3ng0s.png -a "system" -u "$URGENCY" "$TITLE" "$MSG"
}

# ─── LOGGING ──────────────────────────────────────────────────────────────────

exec > >(tee -a "$LOG_FILE") 2>&1
echo ""
echo "═══════════════════════════════════════"
echo " Monthly Update — $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════"

# ─── NOTIFY START ─────────────────────────────────────────────────────────────

notify "🔄 System Update" "Monthly update starting. System packages are being refreshed..." normal

# ─── SNAPSHOT INSTALLED VERSIONS BEFORE UPDATE ────────────────────────────────

echo "[*] Snapshotting pre-update package versions..."
declare -A PRE_VERSIONS
for pkg in "${IMPORTANT_PKGS[@]}"; do
    ver=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}' || true)
    PRE_VERSIONS["$pkg"]="$ver"
done

# ─── RUN UPDATE ───────────────────────────────────────────────────────────────

echo "[*] Running pacman -Syy..."
pacman -Syy --noconfirm

echo "[*] Running pacman -Syu..."
pacman -Syu --noconfirm

echo "[+] Package update complete."

# ─── CHECK WHAT CHANGED ───────────────────────────────────────────────────────

echo "[*] Checking for important package updates..."
UPDATED_IMPORTANT=()
KERNEL_UPDATED=false

for pkg in "${IMPORTANT_PKGS[@]}"; do
    NEW_VER=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}' || true)
    OLD_VER="${PRE_VERSIONS[$pkg]:-}"

    if [ -n "$NEW_VER" ] && [ "$OLD_VER" != "$NEW_VER" ]; then
        UPDATED_IMPORTANT+=("$pkg: $OLD_VER → $NEW_VER")
        echo "[!] Updated: $pkg $OLD_VER -> $NEW_VER"

        # Check if kernel was updated
        for kpkg in "${KERNEL_PKGS[@]}"; do
            [ "$pkg" = "$kpkg" ] && KERNEL_UPDATED=true
        done
    fi
done

# ─── FIND PACNEW FILES ────────────────────────────────────────────────────────

echo "[*] Searching for .pacnew files..."
PACNEW_FILES=()
while IFS= read -r -d '' f; do
    PACNEW_FILES+=("$f")
done < <(find /etc -name "*.pacnew" -print0 2>/dev/null)

echo "[*] Found ${#PACNEW_FILES[@]} .pacnew file(s)."

# ─── BUILD TMUX SESSION WITH VIMDIFF ─────────────────────────────────────────

if [ ${#PACNEW_FILES[@]} -gt 0 ]; then
    echo "[*] Setting up tmux session '$TMUX_SESSION' with vimdiff panes..."

    # Kill existing session if present
    run_as_user tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

    FIRST=true
    for pacnew in "${PACNEW_FILES[@]}"; do
        ORIGINAL="${pacnew%.pacnew}"
        if [ ! -f "$ORIGINAL" ]; then
            echo "[!] No original found for $pacnew, skipping."
            continue
        fi

        if $FIRST; then
            run_as_user tmux new-session -d -s "$TMUX_SESSION" -n "$(basename "$ORIGINAL")" \
                "sudo vimdiff '$ORIGINAL' '$pacnew'; sudo rm '$pacnew'"
            FIRST=false
        else
            run_as_user tmux new-window -t "$TMUX_SESSION" -n "$(basename "$ORIGINAL")" \
                "sudo vimdiff '$ORIGINAL' '$pacnew'; sudo rm '$pacnew'"
        fi
    done

    PACNEW_MSG="Found ${#PACNEW_FILES[@]} .pacnew file(s).\nOpen with: tmux attach -t $TMUX_SESSION"
else
    PACNEW_MSG="No .pacnew files found. Nothing to merge."
fi

# ─── NOTIFY COMPLETION ────────────────────────────────────────────────────────

# Build notification message
NOTIFY_BODY="$PACNEW_MSG"

if [ ${#UPDATED_IMPORTANT[@]} -gt 0 ]; then
    IMPORTANT_STR=$(printf '%s\n' "${UPDATED_IMPORTANT[@]}" | head -5 | tr '\n' '\n')
    NOTIFY_BODY="$NOTIFY_BODY\n\nImportant updates:\n$IMPORTANT_STR"
fi

if $KERNEL_UPDATED; then
    notify "⚠️ Kernel Updated — Reboot Required" \
        "A kernel package was updated. Please reboot when ready.\n\n$NOTIFY_BODY" \
        critical
    echo "[!] KERNEL WAS UPDATED — reboot required."
elif [ ${#UPDATED_IMPORTANT[@]} -gt 0 ]; then
    notify "✅ Update Complete — Action May Be Required" \
        "$NOTIFY_BODY" normal
else
    notify "✅ Update Complete" \
        "All packages up to date. $PACNEW_MSG" low
fi

# ─── DONE ─────────────────────────────────────────────────────────────────────

echo "[+] Monthly update finished at $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════"
