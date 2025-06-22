#!/bin/bash

# ============================================
# AUTO INSTALL MongoDB 6.0 untuk Ubuntu 20.04
# ============================================

set -e

echo "==> Menginstall dependencies..."
apt update && apt install -y wget curl gnupg lsb-release

echo "==> Mengimpor MongoDB GPG key..."
wget -qO - https://pgp.mongodb.com/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg

echo "==> Menambahkan MongoDB repository..."
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" \
    > /etc/apt/sources.list.d/mongodb-org-6.0.list

echo "==> Update repositori dan install MongoDB..."
apt update
apt install -y mongodb-org

echo "==> Mengaktifkan dan menjalankan MongoDB..."
systemctl enable mongod
systemctl start mongod

echo "✅ MongoDB berhasil diinstall dan berjalan!"
echo "📦 Cek status: systemctl status mongod"
