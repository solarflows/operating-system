#!/bin/bash
set -e

USER="root"

# Run dockerd
dockerd -s vfs &> /dev/null &

# set docker use proxy by default, to ensure buildx can pull images from the registry
cat > /etc/docker/daemon.json <<'EOF'
{
  "data-root": "/var/lib/docker",
  "proxies": {
    "no-proxy": "*.local,localhost,127.0.0.0/8,*.lan",
    "http-proxy": "http://10.0.189.1:10708",
    "https-proxy": "http://10.0.189.1:10708"
  }
}
EOF

# Setup local group, if not existing
if [ "${BUILDER_GID:-0}" -ne 0 ] && ! getent group "${BUILDER_GID:-0}"; then
  groupadd -g "${BUILDER_GID}" builder
fi

# Setup local user
if [ "${BUILDER_UID:-0}" -ne 0 ]; then
  useradd -m -u "${BUILDER_UID}" -g "${BUILDER_GID}" -G docker,sudo builder
  echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
  # Make sure cache is accessible by builder
  chown "${BUILDER_UID}:${BUILDER_GID}" /cache
  # Make sure output is accessible by builder (if anonymous volume is used)
  chown "${BUILDER_UID}:${BUILDER_GID}" /build/output || true
  USER="builder"
fi

if CMD="$(command -v "$1")"; then
  shift
  sudo -H -u ${USER} "$CMD" "$@"
else
  echo "Command not found: $1"
  exit 1
fi
