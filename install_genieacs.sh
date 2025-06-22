#!/bin/bash

# ============================================
# AUTO INSTALL GENIEACS TANPA MONGODB
# By cahganteng | Tested on Ubuntu 20.04 / 22.04
# ============================================

set -e

echo "==> Update dan install dependensi..."
apt update && apt upgrade -y
apt install -y curl gnupg build-essential git python3-minimal make g++ nodejs npm

echo "==> Clone source GenieACS..."
cd /opt
git clone https://github.com/genieacs/genieacs.git
cd genieacs

echo "==> Install dependencies NPM..."
npm install

echo "==> Build GenieACS..."
npm run build

echo "==> Buat file environment config..."
cat <<EOF > /opt/genieacs/genieacs.env
UI_JWT_SECRET=genieacs-secret-key
EOF

echo "==> Buat service systemd..."

# CWMP
cat <<EOF > /etc/systemd/system/genieacs-cwmp.service
[Unit]
Description=GenieACS CWMP
After=network.target

[Service]
WorkingDirectory=/opt/genieacs
ExecStart=$(which node) dist/bin/genieacs-cwmp
Restart=always
EnvironmentFile=/opt/genieacs/genieacs.env

[Install]
WantedBy=multi-user.target
EOF

# NBI
cat <<EOF > /etc/systemd/system/genieacs-nbi.service
[Unit]
Description=GenieACS NBI
After=network.target

[Service]
WorkingDirectory=/opt/genieacs
ExecStart=$(which node) dist/bin/genieacs-nbi
Restart=always
EnvironmentFile=/opt/genieacs/genieacs.env

[Install]
WantedBy=multi-user.target
EOF

# FS
cat <<EOF > /etc/systemd/system/genieacs-fs.service
[Unit]
Description=GenieACS FS
After=network.target

[Service]
WorkingDirectory=/opt/genieacs
ExecStart=$(which node) dist/bin/genieacs-fs
Restart=always
EnvironmentFile=/opt/genieacs/genieacs.env

[Install]
WantedBy=multi-user.target
EOF

# UI
cat <<EOF > /etc/systemd/system/genieacs-ui.service
[Unit]
Description=GenieACS UI
After=network.target

[Service]
WorkingDirectory=/opt/genieacs
ExecStart=$(which node) dist/bin/genieacs-ui
Restart=always
EnvironmentFile=/opt/genieacs/genieacs.env

[Install]
WantedBy=multi-user.target
EOF

echo "==> Reload dan aktifkan layanan GenieACS..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui
systemctl start genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui

echo "✅ Selesai! GenieACS sudah berjalan..."
echo "Akses UI: http://<IP-Server>:3000"
echo "Login default bisa dibuat via MongoDB langsung (contoh bisa saya bantu)"
