#!/bin/bash
set -e

# Run as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "Updating package list..."
apt update -y

# -----------------------------
# Docker
# -----------------------------
if command -v docker &> /dev/null; then
  echo "Docker is already installed ($(docker --version))"
else
  echo "Installing Docker..."

  apt install -y ca-certificates curl

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list

  apt update -y
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  if [[ -n "${SUDO_USER}" ]]; then
    usermod -aG docker "${SUDO_USER}"
    echo "⚠️  Added ${SUDO_USER} to docker group. LOG OUT AND BACK IN for this to take effect!"
  fi

  systemctl enable docker
  systemctl start docker
  echo "✓ Docker installed successfully"
fi

# -----------------------------
# Docker Compose
# -----------------------------
if docker compose version &> /dev/null; then
  echo "Docker Compose is available ($(docker compose version))"
else
  echo "⚠️  Docker Compose not found (should be installed with Docker)"
fi

# -----------------------------
# Python 3.9+
# -----------------------------
PYTHON_VERSION_CHECK=$(python3 -c 'import sys; print(1 if sys.version_info >= (3,9) else 0)' 2>/dev/null || echo 0)

if command -v python3 &> /dev/null && [[ "$PYTHON_VERSION_CHECK" == "1" ]]; then
  echo "Python 3.9+ is already installed ($(python3 --version))"
else
  echo "Installing Python 3 and pip..."
  apt install -y python3 python3-pip python3-venv
fi

# -----------------------------
# pip
# -----------------------------
if ! python3 -m pip --version &> /dev/null; then
  echo "Installing pip..."
  apt install -y python3-pip
fi

# -----------------------------
# Django
# -----------------------------
if python3 -m pip show django &> /dev/null; then
  DJANGO_VERSION=$(python3 -m pip show django | grep Version | cut -d' ' -f2)
  echo "Django is already installed (version $DJANGO_VERSION)"
else
  echo "Installing Django..."
  # Install system-wide when running as root, or recommend venv
  if [[ -n "${SUDO_USER}" ]]; then
    echo "ℹ️  Note: Consider using a virtual environment for Django projects"
    echo "    Create one with: python3 -m venv myproject_env"
  fi
  python3 -m pip install django
  echo "✓ Django installed successfully"
fi

echo ""
echo "========================================="
echo "Installation complete!"
echo "========================================="
echo "Installed:"
echo "  - Docker: $(docker --version 2>/dev/null || echo 'check failed')"
echo "  - Docker Compose: $(docker compose version 2>/dev/null || echo 'check failed')"
echo "  - Python: $(python3 --version)"
echo "  - Django: $(python3 -m django --version 2>/dev/null || echo 'check failed')"
echo ""
if [[ -n "${SUDO_USER}" ]]; then
  echo "⚠️  IMPORTANT: Log out and back in to use Docker without sudo"
fi