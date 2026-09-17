FROM python:3.14-slim

# https://github.com/stablyai/orca/releases/download/v1.4.205/orca-linux.AppImage
# https://www.npmjs.com/package/opencode-ai/v/1.18.31
# https://nodejs.org/en/download/
ARG ORCA_VERSION=v1.4.205
ARG OPENCODE_VERSION=1.18.31
ARG NODE_VERSION=22

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/orca
ENV XDG_DATA_HOME=/home/orca/.local/share
ENV XDG_CONFIG_HOME=/home/orca/.config
ENV LIBGL_ALWAYS_SOFTWARE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq \
    xvfb \
    libatk-bridge2.0-0t64 \
    libatspi2.0-0 \
    libasound2t64 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    libxss1 \
    procps \
    util-linux \
    xauth \
 && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash orca && \
    mkdir -p /opt/orca && \
    curl -L https://github.com/stablyai/orca/releases/download/${ORCA_VERSION}/orca-linux.AppImage -o /opt/orca/orca-linux.AppImage && \
    chmod 755 /opt/orca/orca-linux.AppImage && \
    mkdir -p /opt/orca/squashfs-root && \
    cd /opt/orca && \
    ./orca-linux.AppImage --appimage-extract && \
    chmod -R a+rX /opt/orca/squashfs-root && \
    mkdir -p /home/orca/.local/share/opencode/log \
        /home/orca/.local/state/opencode \
        /home/orca/.config/opencode \
        /workspace && \
    chown -R orca:orca /home/orca /workspace && \
    chmod -R 755 /home/orca/.local && \
    chmod -R 755 /home/orca/.config && \
    npm i -g "opencode-ai@${OPENCODE_VERSION}" && \
    npm cache clean --force && \
    echo "opencode version ${OPENCODE_VERSION} installed successfully."

USER orca
WORKDIR /workspace

EXPOSE 6768

ENTRYPOINT ["/opt/orca/squashfs-root/AppRun"]
CMD ["serve", "--port", "6768", "--pairing-address", "orca", "--json"]