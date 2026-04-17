FROM ubuntu:22.04

# ইনস্টলেশনের সময় যেকোনো পপ-আপ বা প্রম্পট বন্ধ করার জন্য
ENV DEBIAN_FRONTEND=noninteractive

# ধাপ ১: শুধু বেসিক টুলস এবং SSH (অপ্রয়োজনীয় ফাইল ছাড়া)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git sudo nano openssh-server ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ধাপ ২: Tailscale ইনস্টল
RUN curl -fsSL https://tailscale.com/install.sh | sh

# ধাপ ৩: SSH কনফিগারেশন এবং পোর্ট ২২ ওপেন
RUN mkdir -p /var/run/sshd && \
    useradd -m -u 1000 devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "devuser:123456" | chpasswd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ধাপ ৪: Render-এর জন্য ttyd
RUN wget -O /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# স্টার্টআপ স্ক্রিপ্ট
COPY start.sh /start.sh
RUN chmod +x /start.sh

USER devuser
WORKDIR /home/devuser

CMD ["/start.sh"]
