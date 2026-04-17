FROM ubuntu:22.04

# apt-get এরর 100 ফিক্স করার জন্য মিরর পরিবর্তন এবং IPv4 ফোর্স করা
RUN sed -i 's/archive.ubuntu.com/mirror.math.princeton.edu/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirror.math.princeton.edu/g' /etc/apt/sources.list && \
    echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

# এবার প্রয়োজনীয় প্যাকেজ এবং Tailscale ইনস্টল
RUN apt-get update && apt-get install -y \
    curl wget git sudo nano openssh-server \
    && curl -fsSL https://tailscale.com/install.sh | sh \
    && rm -rf /var/lib/apt/lists/*

# SSH কনফিগারেশন এবং ইউজার তৈরি
RUN mkdir /var/run/sshd && \
    useradd -m -u 1000 devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "devuser:123456" | chpasswd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Render-এর পোর্ট চালু রাখার জন্য ttyd
RUN wget -O /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# স্টার্টআপ স্ক্রিপ্ট কপি করা
COPY start.sh /start.sh
RUN chmod +x /start.sh

USER devuser
WORKDIR /home/devuser

CMD ["/start.sh"]
