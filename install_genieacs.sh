#!/bin/bash

# ============================================
# AUTO INSTALL GENIEACS di Ubuntu 20.04
# By ChatGPT | Versi 2025
# ============================================

set -e

echo "==> Update system & install dependencies..."
apt update && apt upgrade -y
apt install -y curl gnupg build-essential git python3-minimal make g++ mongodb-org-shell

echo "==> Install Node.js v18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "==> Tambah MongoDB 6.0 repository..."
wget -qO - https://pgp.mongodb.com/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" \
  > /etc/apt/sources.list.d/mongodb-org-6.0.list

apt update
apt install -y mongodb-org

echo "==> Jalankan MongoDB..."
systemctl enable mongod
systemctl start mongod

echo "==> Clone GenieACS..."
cd /opt
git clone https://github.com/genieacs/genieacs.git
cd genieacs

echo "==> Install dependency GenieACS..."
npm install
npm run build

echo "==> Buat user admin di MongoDB..."
mongo <<EOF
use genieacs
db.users.insertOne({
  username: "admin",
  password: "\$2b\$10\$YzckvOwEDxZrVMeSBZ8y2uLwBuvRDLgNv0cPmfPiWkt.vslOS3Kry", // password: admin
  roles: ["admin"]
})
EOF

echo "==> Buat file env..."
cat <<EOL > genieacs.env
UI_JWT_SECRET=genieacs-secret-key
EOL

echo "==> Buat service systemd..."
cat <<EOF > /etc/systemd/system/genieacs-cwmp.service
[Unit]
Description=GenieACS CWMP
After=network.target

[Service]
WorkingDirectory=/opt/genieacs
ExecStart=/usr/bin/node dist/bin/genieacs-cwmp
Restart=always
EnvironmentFile=/opt/genieacs/genieacs.env

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/genieacs-nbi.service
[Unit]
Description=GenieACS NBI
After=network.target

[Service]
WorkingDirectory=/opt/genieacs
ExecStart=/usr/bin/node dist/bin/genieacs-nbi
Restart=always
EnvironmentFile=/opt/genieacs/genieacs.env

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/genieacs-fs.service
[Unit]
Description=GenieACS FS
After=network.target

[Service]
WorkingDirectory=/opt/genieacs
ExecStart=/usr/bin/node dist/bin/genieacs-fs
Restart=always
EnvironmentFile=/opt/genieacs/genieacs.env

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/genieacs-ui.service
[Unit]
Description=GenieACS UI
After=network.target

[Service]
WorkingDirectory=/opt/genieacs
ExecStart=/usr/bin/node dist/bin/genieacs-ui
Restart=always
EnvironmentFile=/opt/genieacs/genieacs.env

[Install]
WantedBy=multi-user.target
EOF

echo "==> Reload & enable semua service GenieACS..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui
systemctl start genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui

echo "✅ SELESAI! GenieACS running..."
echo "Akses UI: http://<IP-Server>:3000"
echo "Login: admin / admin"
