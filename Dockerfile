FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 && \
    sed -i 's/archive.ubuntu.com/mirrors.kernel.org/g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's/security.ubuntu.com/mirrors.kernel.org/g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git sudo nano openssh-server ca-certificates htop procps iproute2 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://tailscale.com/install.sh | sh

RUN mkdir -p /var/run/sshd && \
    useradd -m -s /bin/bash -u 1010 devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "devuser:123456" | chpasswd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowUsers devuser" >> /etc/ssh/sshd_config

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
