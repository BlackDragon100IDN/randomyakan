#!/bin/bash
# =========================================
# Randomyakan Cleaner + Network Fresh Reset
# Author: AutoClean++
# Function:
# - Remove randomyakan
# - Disable random MAC
# - Set permanent MAC
# - Clear network cache
# - Reset WiFi stack
# - Reset NetworkManager state
# - Flush DNS
# - Full network fresh
# =========================================

# Auto sudo
[ "$EUID" -ne 0 ] && exec sudo "$0" "$@"

echo "========================================="
echo "🧹 Randomyakan Cleaner + Network Fresh"
echo "⏰ $(date)"
echo "========================================="

echo "[1/9] 🔥 Menghapus file randomyakan..."

rm -rf /root/randomyakan
rm -f /usr/local/bin/randomyakan.sh
rm -f /root/randomyakan.sh
rm -f /home/*/randomyakan.sh 2>/dev/null

echo "✅ Randomyakan file removed"

echo "[2/9] 🔍 Scan sisa randomyakan..."
FOUND=$(find / -iname "*randomyakan*" 2>/dev/null)
if [ -z "$FOUND" ]; then
    echo "✅ Tidak ada sisa randomyakan"
else
    echo "⚠️ Masih ada file:"
    echo "$FOUND"
fi

echo "[3/9] 🔧 Disable random MAC (NetworkManager)..."

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

echo "[4/9] 🔒 Global config anti-random..."
cat <<EOF > /etc/NetworkManager/conf.d/00-disable-random-mac.conf
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
ethernet.cloned-mac-address=permanent
gsm.cloned-mac-address=permanent
EOF

echo "✅ Global anti-random config applied"

echo "[5/9] 🧹 Clear network cache & state..."

# Stop services
systemctl stop NetworkManager
systemctl stop systemd-resolved 2>/dev/null

# Clear NM cache/state
rm -rf /var/lib/NetworkManager/*
rm -rf /etc/NetworkManager/system-connections/*

# Clear resolv cache
rm -f /etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

echo "✅ Network cache cleared"

echo "[6/9] 🔄 Reset WiFi stack..."

# Reset WiFi driver
rfkill unblock all
nmcli radio wifi off
sleep 2
nmcli radio wifi on

echo "✅ WiFi stack reset"

echo "[7/9] 🌐 Flush DNS cache..."

systemd-resolve --flush-caches 2>/dev/null
resolvectl flush-caches 2>/dev/null

echo "✅ DNS cache flushed"

echo "[8/9] 🔁 Restart full networking..."

systemctl start systemd-resolved 2>/dev/null
systemctl start NetworkManager
sleep 5

echo "✅ NetworkManager restarted"

echo "[9/9] 🧪 Verifikasi MAC:"
for i in /sys/class/net/*/address; do
    IFACE=$(basename $(dirname $i))
    MAC=$(cat $i)
    echo " - $IFACE : $MAC"
done

echo "========================================="
echo "✅ CLEANING SELESAI TOTAL"
echo "🔒 Randomyakan removed"
echo "🛡️ Random MAC disabled"
echo "📡 MAC permanent enforced"
echo "🧹 Network cache cleared"
echo "📶 WiFi reset"
echo "🌐 DNS flushed"
echo "🚀 Network fresh like new"
echo "🏁 One-run script done"
echo "========================================="
