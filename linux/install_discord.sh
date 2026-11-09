#!/bin/bash
set -euo pipefail

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

wget -O "$tmp/discord.deb" "https://discord.com/api/download?platform=linux&format=deb"
sudo apt-get install -y "$tmp/discord.deb"
