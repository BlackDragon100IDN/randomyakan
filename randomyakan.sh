#!/bin/bash
# =========================================
# Randomyakan - WiFi MAC Randomizer Script
# Universal fix
# =========================================

# Auto sudo
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"

# Deteksi interface WiFi aktif
IFACE=$(nmcli -t -f DEVICE,TYPE,STATE device status | grep -E '^.*:wifi:connected$' | cut -d: -f1)

if [ -z "$IFACE" ]; then
    echo "❌ Tidak ada koneksi WiFi aktif"
    exit 1
fi

# Deteksi nama koneksi WiFi
CONN=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":$IFACE$" | cut -d: -f1)

echo "📡 WiFi aktif   : $CONN"
echo "📶 Interface    : $IFACE"
echo "🎲 Mode         : RANDOM MAC"
echo "🔁 Randomizing MAC address..."

# Set random MAC
nmcli connection modify "$CONN" wifi.cloned-mac-address random

echo "🔌 Restart koneksi WiFi..."
nmcli device disconnect "$IFACE"
sleep 2
nmcli device connect "$IFACE"

echo ""
echo "✅ SUCCESS!"
echo "📍 MAC address sekarang:"
ip link show "$IFACE" | grep link/ether
echo "========================================="
