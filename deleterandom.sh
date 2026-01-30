#!/bin/bash
# =========================================
# Randomyakan Cleaner + WiFi Restart ONLY
# Author: AutoClean++
# Function:
# - Remove randomyakan
# - Disable random MAC (WiFi only)
# - Set permanent MAC (WiFi only)
# - Restart NetworkManager only
# - NO file delete
# - NO cache delete
# - NO reset radio
# =========================================

# Auto sudo
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"

echo "========================================="
echo "🧹 Randomyakan Cleaner + WiFi Restart ONLY"
echo "⏰ $(date)"
echo "========================================="

echo "[1/4] 🔥 Menghapus file randomyakan..."

rm -rf /root/randomyakan
rm -f /usr/local/bin/randomyakan.sh
rm -f /root/randomyakan.sh
rm -f /home/*/randomyakan.sh 2>/dev/null

echo "✅ Randomyakan file removed"

echo "[2/4] 🔧 Disable random MAC (WiFi ONLY)..."

# WiFi only
for c in $(nmcli -t -f NAME,TYPE connection show | grep ":wifi" | cut -d: -f1); do
    nmcli connection modify "$c" 802-11-wireless.cloned-mac-address permanent
done

echo "✅ WiFi MAC set to permanent"

echo "[3/4] 🔒 Global WiFi anti-random config..."
cat <<EOF > /etc/NetworkManager/conf.d/00-disable-random-mac-wifi.conf
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
EOF

echo "✅ WiFi anti-random config applied"

echo "[4/4] 🔁 Restart NetworkManager (WiFi refresh only)..."

systemctl restart NetworkManager
sleep 5

echo "========================================="
echo "✅ WIFI REFRESH SELESAI"
echo "📶 WiFi refreshed"
echo "🔒 Random MAC WiFi OFF"
echo "📡 MAC WiFi permanent"
echo "🔁 NetworkManager restarted"
echo "🏁 One-run script done"
echo "========================================="
