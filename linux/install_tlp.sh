#!/bin/bash
set -e

# ============================================
# TLP setup script for ThinkPad X13 Gen 5
# Ubuntu 24.04
#
# 実行方法:
#   chmod +x install_tlp.sh
#   ./install_tlp.sh    # no need to run the whole script with sudo
#
# --------------------------------------------
# TLP サービス操作メモ:
#
#   サービス有効化:
#     sudo systemctl enable tlp
#
#   サービス無効化:
#     sudo systemctl disable tlp
#
#   サービス開始:
#     sudo systemctl start tlp
#
#   サービス停止:
#     sudo systemctl stop tlp
#
#   状態確認:
#     systemctl status tlp
# ============================================

echo "== Install TLP =="
sudo apt update
sudo apt install -y tlp

echo "== Disable power-profiles-daemon (conflict prevention) =="
sudo systemctl stop power-profiles-daemon || true
sudo systemctl disable power-profiles-daemon || true

echo "== Backup existing tlp.conf =="
if [ -f /etc/tlp.conf ]; then
    sudo cp /etc/tlp.conf /etc/tlp.conf.bak.$(date +%Y%m%d%H%M%S)
fi

echo "== Write tlp.conf =="
sudo tee /etc/tlp.conf > /dev/null << 'EOF'
# ==================================================
# ThinkPad X13 Gen 5 - Recommended minimal TLP config
# Ubuntu 24.04
# ==================================================

# --- CPU scaling ---
CPU_SCALING_GOVERNOR_ON_AC=schedutil
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# --- Energy Performance Policy ---
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# --- Intel EPP ---
CPU_EPP_ON_AC=balance_performance
CPU_EPP_ON_BAT=power

# --- PCIe / NVMe ---
PCIE_ASPM_ON_BAT=powersupersave

# --- Wi-Fi ---
WIFI_PWR_ON_BAT=on

# --- USB autosuspend (safe exclusions) ---
USB_AUTOSUSPEND=1
USB_EXCLUDE_BTUSB=1
USB_EXCLUDE_AUDIO=1

# --- Runtime PM ---
RUNTIME_PM_ON_BAT=auto

# --- Battery charge thresholds (longevity focused) ---
START_CHARGE_THRESH_BAT0=85
STOP_CHARGE_THRESH_BAT0=90
EOF

echo "== Enable & start TLP =="
sudo systemctl enable tlp
sudo systemctl start tlp

echo "== Apply TLP settings =="
sudo tlp start

echo "== Done =="
echo "Check status with:"
echo "  sudo tlp-stat -s"
echo "  sudo tlp-stat -p"
echo "  sudo tlp-stat -b"
