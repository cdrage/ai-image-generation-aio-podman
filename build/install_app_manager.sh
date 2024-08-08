#!/usr/bin/env bash
set -e

git clone https://github.com/cdrage/app-manager.git /app-manager
cd /app-manager
git checkout main
npm install
