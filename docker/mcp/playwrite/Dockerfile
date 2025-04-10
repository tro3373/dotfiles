FROM node:23-slim

# 必要な依存関係をインストール

ENV DEPS="wget unzip gnupg apt-transport-https"
RUN apt-get update && apt-get install -y $DEPS

# /optディレクトリ内にChromeをインストールするためのディレクトリを作成
RUN mkdir -p /opt/chrome && \
  # Chromeのダウンロードとインストール
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    ln -s /usr/bin/google-chrome-stable /opt/chrome/google

WORKDIR /app
RUN npm init -y && \
    npm install @playwright/mcp@latest && \
    npx playwright install --with-deps

ENTRYPOINT ["npx", "@playwright/mcp@latest", "--headless"]
