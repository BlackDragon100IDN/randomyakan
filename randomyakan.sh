#!/bin/bash
# =========================================
# Randomyakan - WiFi MAC Randomizer Script
# Repo  : https://github.com/BlackDragon100IDN/randomyakan
# Author: BlackDragon100IDN
# =========================================

# Auto sudo
if [ "$EUID" -ne 0 ]; then
    echo "🔐 Meminta akses root..."
    exec sudo "$0" "$@"
fi

# Detect active WiFi connection
CONN=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep wifi | cut -d: -f1)

if [ -z "$CONN" ]; then
    echo "❌ Tidak ada koneksi WiFi aktif"
    exit 1
fi

echo "📡 WiFi aktif  : $CONN"
echo "🎲 Mode       : RANDOM MAC"
echo "🔁 Proses     : Randomisasi MAC address..."

# Set random MAC
nmcli connection modify "$CONN" wifi.cloned-mac-address random

echo "🔌 Restart koneksi WiFi..."
nmcli connection down "$CONN"
sleep 2
nmcli connection up "$CONN"

echo ""
echo "✅ SUCCESS!"
echo "📍 MAC address sekarang:"
ip link show wlan0 | grep link/ether
echo "========================================="
