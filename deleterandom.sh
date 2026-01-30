#!/bin/bash
# =========================================
# Randomyakan Cleaner + Safe Network Reset
# Author: AutoClean++
# Function:
# - Remove randomyakan
# - Disable random MAC
# - Set permanent MAC
# - Clear network cache (SAFE)
# - Reset NetworkManager state (SAFE)
# - Flush DNS
# - Restart NetworkManager
# - Keep saved WiFi/Hotspot configs
# =========================================

# Auto sudo
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"

echo "========================================="
echo "🧹 Randomyakan Cleaner + SAFE Cache Reset"
echo "⏰ $(date)"
echo "========================================="

echo "[1/7] 🔥 Menghapus file randomyakan..."

rm -rf /root/randomyakan
rm -f /usr/local/bin/randomyakan.sh
rm -f /root/randomyakan.sh
rm -f /home/*/randomyakan.sh 2>/dev/null

echo "✅ Randomyakan file removed"

echo "[2/7] 🔍 Scan sisa randomyakan..."
FOUND=$(find / -iname "*randomyakan*" 2>/dev/null)
if [ -z "$FOUND" ]; then
    echo "✅ Tidak ada sisa randomyakan"
else
    echo "⚠️ Masih ada file:"
    echo "$FOUND"
fi

echo "[3/7] 🔧 Disable random MAC (NetworkManager)..."

# WiFi
for c in $(nmcli -t -f NAME,TYPE connection show | grep ":wifi" | cut -d: -f1); do
    nmcli connection modify "$c" 802-11-wireless.cloned-mac-address permanent
done

# Ethernet
for c in $(nmcli -t -f NAME,TYPE connection show | grep ":ethernet" | cut -d: -f1); do
    nmcli connection modify "$c" ethernet.cloned-mac-address permanent
done

# GSM
for c in $(nmcli -t -f NAME,TYPE connection show | grep ":gsm" | cut -d: -f1); do
    nmcli connection modify "$c" gsm.cloned-mac-address permanent
done

echo "✅ MAC set to permanent"

echo "[4/7] 🔒 Global config anti-random..."
cat <<EOF > /etc/NetworkManager/conf.d/00-disable-random-mac.conf
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
ethernet.cloned-mac-address=permanent
gsm.cloned-mac-address=permanent
EOF

echo "✅ Global anti-random config applied"

echo "[5/7] 🧹 Clear network cache (SAFE MODE)..."

# Stop services
systemctl stop NetworkManager
systemctl stop systemd-resolved 2>/dev/null

# SAFE cache clear (TIDAK hapus saved connections)
rm -rf /var/lib/NetworkManager/*.lease
rm -rf /var/lib/NetworkManager/seen-bssids
rm -rf /var/lib/NetworkManager/internal-*
rm -rf /var/lib/NetworkManager/timestamps
rm -rf /var/lib/NetworkManager/state
rm -rf /run/NetworkManager/*

# Reset resolv cache
rm -f /etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

echo "✅ Network runtime cache cleared (SAFE)"

echo "[6/7] 🌐 Flush DNS cache..."
systemd-resolve --flush-caches 2>/dev/null
resolvectl flush-caches 2>/dev/null
echo "✅ DNS cache flushed"

echo "[7/7] 🔁 Restart NetworkManager..."

systemctl start systemd-resolved 2>/dev/null
systemctl start NetworkManager
sleep 5

echo "✅ NetworkManager restarted"

echo "========================================="
echo "✅ CLEANING SELESAI (SAFE MODE)"
echo "🔒 Randomyakan removed"
echo "🛡️ Random MAC disabled"
echo "📡 MAC permanent enforced"
echo "🧹 Cache jaringan dibersihkan"
echo "📶 WiFi & hotspot tetap tersimpan"
echo "🌐 DNS flushed"
echo "🔁 NetworkManager restarted"
echo "🏁 One-run script done"
echo "========================================="
