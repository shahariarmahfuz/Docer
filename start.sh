#!/bin/bash
set -e

mkdir -p /var/run/sshd /var/lib/tailscale

# tailscaled চালু
tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state &
TS_PID=$!

sleep 5

# auth key থাকলে connect করবে
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname=render-ubuntu
fi

# debug দরকার হলে Tailscale IP দেখাবে
tailscale ip || true

# ssh server foreground-এ চালু থাকবে
exec /usr/sbin/sshd -D -e
