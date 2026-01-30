#!/bin/bash
# =========================================
# Randomyakan Cleaner - One Run Script
# Author: AutoClean
# Function:
# - Remove randomyakan
# - Disable random MAC
# - Set permanent MAC
# - Reset NetworkManager
# - Verify status
# =========================================

# Auto sudo
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"

echo "========================================="
echo "🧹 Randomyakan Cleaner - ONE RUN MODE"
echo "⏰ $(date)"
echo "========================================="

echo "[1/6] 🔥 Menghapus file randomyakan..."

rm -rf /root/randomyakan
rm -f /usr/local/bin/randomyakan.sh
rm -f /root/randomyakan.sh
rm -f /home/*/randomyakan.sh 2>/dev/null

echo "✅ Randomyakan file removed"

echo "[2/6] 🔍 Scan sisa randomyakan..."
FOUND=$(find / -iname "*randomyakan*" 2>/dev/null)
if [ -z "$FOUND" ]; then
    echo "✅ Tidak ada sisa randomyakan"
else
    echo "⚠️ Masih ada file:"
    echo "$FOUND"
fi

echo "[3/6] 🔧 Disable random MAC (NetworkManager)..."

# WiFi connections
for c in $(nmcli -t -f NAME,TYPE connection show | grep ":wifi" | cut -d: -f1); do
    nmcli connection modify "$c" 802-11-wireless.cloned-mac-address permanent
done

# Ethernet connections
for c in $(nmcli -t -f NAME,TYPE connection show | grep ":ethernet" | cut -d: -f1); do
    nmcli connection modify "$c" ethernet.cloned-mac-address permanent
done

# GSM connections
for c in $(nmcli -t -f NAME,TYPE connection show | grep ":gsm" | cut -d: -f1); do
    nmcli connection modify "$c" gsm.cloned-mac-address permanent
done

echo "✅ MAC set to permanent"

echo "[4/6] 🔒 Global config anti-random..."
cat <<EOF > /etc/NetworkManager/conf.d/00-disable-random-mac.conf
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
ethernet.cloned-mac-address=permanent
gsm.cloned-mac-address=permanent
EOF

echo "✅ Global anti-random config applied"

echo "[5/6] 🔁 Restart NetworkManager..."
systemctl restart NetworkManager
sleep 3

echo "[6/6] 🧪 Verifikasi MAC:"
for i in /sys/class/net/*/address; do
    IFACE=$(basename $(dirname $i))
    MAC=$(cat $i)
    echo " - $IFACE : $MAC"
done

echo "========================================="
echo "✅ CLEANING SELESAI"
echo "🔒 Randomyakan removed"
echo "🛡️ Random MAC disabled"
echo "📡 MAC permanent enforced"
echo "🏁 One-run script done"
echo "========================================="
