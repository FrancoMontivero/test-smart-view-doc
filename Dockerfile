FROM debian:latest

# Instalar dependencias necesarias
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    sudo \
    unzip \
    docker.io \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Instalar Act
RUN curl -s https://api.github.com/repos/nektos/act/releases/latest \
    | grep "browser_download_url.*Linux_x86_64.tar.gz\"" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi - && \
    mkdir -p /tmp/act && \
    tar -xzf act_Linux_x86_64.tar.gz -C /tmp/act && \
    chmod +x /tmp/act/act && \
    mv /tmp/act/act /usr/local/bin/act && \
    rm -rf /tmp/act act_Linux_x86_64.tar.gz

# Configurar el punto de entrada
ENTRYPOINT ["act"]

