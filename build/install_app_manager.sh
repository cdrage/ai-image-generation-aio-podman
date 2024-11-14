#!/usr/bin/env bash
set -e

# Install node / npm
curl -fsSL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt-get install -y nodejs
node -v


git clone https://github.com/cdrage/app-manager.git /app-manager
cd /app-manager
git checkout main
npm install
