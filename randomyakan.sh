#!/bin/bash
# =========================================
# Randomyakan - WiFi MAC Randomizer Script
# Repo  : https://github.com/BlackDragon100IDN/randomyakan
# Author: BlackDragon100IDN
# =========================================

# Auto sudo
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"

# Detect active WiFi connection (correct type filter)
CONN=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep "802-11-wireless" | cut -d: -f1)
IFACE=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep "802-11-wireless" | cut -d: -f3)

if [ -z "$CONN" ] || [ -z "$IFACE" ]; then
    echo "❌ Tidak ada koneksi WiFi aktif"
    exit 1
fi

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
