# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Install core utilities (excluding eza, which we install manually)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        curl \
        git \
        zsh \
        tmux \
        neovim \
        python3-pip \
        nodejs npm \
        bat \
        zoxide \
        fzf \
        ripgrep \
        stow \
        locales && \
    # Clean apt caches
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install latest stable eza binary from GitHub releases
RUN wget -qO- https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/eza && \
    ln -s /usr/local/bin/eza /usr/local/bin/exa || true

# Set locale (helps tools like neovim)
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Create symlink for bat (Ubuntu ships it as batcat)
RUN ln -s $(which batcat) /usr/local/bin/bat || true

# Install latest stable Neovim AppImage
RUN curl -L -o /tmp/nvim.appimage https://github.com/neovim/neovim/releases/download/stable/nvim.appimage && \
    chmod u+x /tmp/nvim.appimage && \
    mv /tmp/nvim.appimage /usr/local/bin/nvim && \
    ln -s /usr/local/bin/nvim /usr/bin/nvim

# Set default shell for vscode user (will be created by the base image)
ARG USERNAME=vscode
RUN usermod --shell /usr/bin/zsh ${USERNAME} || true

# Switch to non‑root user for the remainder
USER ${USERNAME}
WORKDIR /workspace

# Ensure Zsh is the default login shell when container starts
ENV SHELL=/usr/bin/zsh

# Expose SSH port (optional, for devcontainer feature)
EXPOSE 22
