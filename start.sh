#!/bin/bash

# SSH এবং Tailscale চালু করা
sudo service ssh start
sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
sleep 3

# Tailscale-এ কানেক্ট করা (Secret থেকে Key নেবে)
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    sudo tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=render-ubuntu
fi

# Render-এর পোর্ট রিকোয়ারমেন্ট মেটানোর জন্য ttyd রান করানো
PORT=${PORT:-10000}
ttyd -p $PORT -W bash
