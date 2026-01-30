#!/bin/bash
# =========================================
# Randomyakan Cleaner + WiFi Only Reset
# Author: AutoClean++
# Function:
# - Remove randomyakan
# - Disable random MAC (WiFi only)
# - Set permanent MAC (WiFi only)
# - Clear WiFi cache only (NO file delete critical)
# - Flush DNS (no resolv.conf delete)
# - Restart NetworkManager
# =========================================

# Auto sudo
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"

echo "========================================="
echo "🧹 Randomyakan Cleaner + WiFi ONLY Reset"
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

echo "[3/6] 🔧 Disable random MAC (WiFi ONLY)..."

# WiFi only
for c in $(nmcli -t -f NAME,TYPE connection show | grep ":wifi" | cut -d: -f1); do
    nmcli connection modify "$c" 802-11-wireless.cloned-mac-address permanent
done

echo "✅ WiFi MAC set to permanent"

echo "[4/6] 🔒 Global WiFi anti-random config..."
cat <<EOF > /etc/NetworkManager/conf.d/00-disable-random-mac-wifi.conf
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
EOF

echo "✅ WiFi anti-random config applied"

echo "[5/6] 🧹 Clear WiFi cache only..."

# Stop NM safely
systemctl stop NetworkManager
systemctl stop systemd-resolved 2>/dev/null

# Clear ONLY WiFi related runtime cache
rm -rf /var/lib/NetworkManager/seen-bssids
rm -rf /var/lib/NetworkManager/timestamps
rm -rf /var/lib/NetworkManager/internal-*
rm -rf /run/NetworkManager/*

echo "✅ WiFi runtime cache cleared"

echo "[6/6] 🌐 Flush DNS + Restart NetworkManager..."

# Flush DNS only (NO file delete)
systemd-resolve --flush-caches 2>/dev/null
resolvectl flush-caches 2>/dev/null

systemctl start systemd-resolved 2>/dev/null
systemctl start NetworkManager
sleep 5

echo "========================================="
echo "✅ WIFI CLEAN SELESAI"
echo "📶 WiFi cache cleared"
echo "🔒 Random MAC WiFi OFF"
echo "📡 MAC WiFi permanent"
echo "🌐 DNS flushed (safe)"
echo "🔁 NetworkManager restarted"
echo "🏁 One-run script done"
echo "========================================="
