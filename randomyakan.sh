#!/bin/bash
# =========================================
# Randomyakan - WiFi MAC Randomizer (ONCE RUN)
# Repo: https://github.com/BlackDragon100IDN/randomyakan.git
# =========================================

# Auto sudo
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"

echo "========================================="
echo "🎯 Randomyakan - Single Run Mode"
echo "⏰ $(date)"
echo "========================================="

# Detect WiFi interface (connected)
IFACE=$(nmcli -t -f DEVICE,TYPE,STATE device status | grep -i ':wifi:connected' | cut -d: -f1 | tr -d ' ')

if [ -z "$IFACE" ]; then
    echo "❌ Tidak ada koneksi WiFi aktif"
    exit 1
fi

# Detect active connection
CONN=$(nmcli -t -f NAME,DEVICE connection show --active | grep ":$IFACE" | cut -d: -f1 | tr -d ' ')

if [ -z "$CONN" ]; then
    echo "❌ Tidak ada koneksi aktif untuk interface $IFACE"
    exit 1
fi

echo "📡 WiFi aktif   : $CONN"
echo "📶 Interface    : $IFACE"
echo "🎲 Mode         : RANDOM MAC (SINGLE EXEC)"

# Random MAC
nmcli connection modify "$CONN" wifi.cloned-mac-address random

echo "🔌 Restart WiFi..."
nmcli device disconnect "$IFACE"
sleep 2
nmcli device connect "$IFACE"

echo "✅ SUCCESS!"
ip link show "$IFACE" | grep link/ether

echo "🏁 Selesai (1x eksekusi)"
