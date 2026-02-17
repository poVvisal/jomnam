#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   sudo bash droplet-setup.sh <dockerhub_username> <deploy_user>
# Example:
#   sudo bash droplet-setup.sh mydockeruser deploy

DOCKERHUB_USER="${1:-}"
DEPLOY_USER="${2:-deploy}"

if [[ -z "${DOCKERHUB_USER}" ]]; then
  echo "Usage: sudo bash droplet-setup.sh <dockerhub_username> <deploy_user>"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[1/8] Updating apt packages"
apt-get update -y
apt-get upgrade -y

echo "[2/8] Installing base tools"
apt-get install -y ca-certificates curl gnupg lsb-release git ufw

echo "[3/8] Installing Docker"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker

echo "[4/8] Creating deploy user if missing"
if ! id -u "${DEPLOY_USER}" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "${DEPLOY_USER}"
fi

usermod -aG docker "${DEPLOY_USER}"
mkdir -p "/home/${DEPLOY_USER}/.ssh"
chown -R "${DEPLOY_USER}:${DEPLOY_USER}" "/home/${DEPLOY_USER}/.ssh"
chmod 700 "/home/${DEPLOY_USER}/.ssh"

echo "[5/8] Preparing app directory"
mkdir -p /opt/trov-tver
chown -R "${DEPLOY_USER}:${DEPLOY_USER}" /opt/trov-tver

echo "[6/8] Configuring firewall"
ufw allow OpenSSH || true
ufw allow 80/tcp || true
ufw allow 443/tcp || true
ufw allow 3001/tcp || true
ufw --force enable

echo "[7/8] Optional hardening"
if grep -q '^#*PasswordAuthentication' /etc/ssh/sshd_config; then
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
else
  echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
fi
systemctl reload ssh || systemctl reload sshd || true

echo "[8/8] Summary"
echo "- Docker installed and running"
echo "- Deploy user: ${DEPLOY_USER} (added to docker group)"
echo "- App directory: /opt/trov-tver"
echo "- UFW enabled (22,80,443,3001)"
echo ""
echo "Next manual step on droplet (as deploy user):"
echo "  docker login -u ${DOCKERHUB_USER}"
echo "Then configure Jenkins credentials and run pipeline."
