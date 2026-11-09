#!/bin/bash
set -euo pipefail

# Docker / QEMU / NVIDIA Container Toolkit install script (Ubuntu)
# 実行方法:
#   ./docker_install.sh              # Docker + QEMU
#   ./docker_install.sh --nvidia     # 上記 + NVIDIA Container Toolkit
#   (スクリプト全体を sudo で実行する必要はありません)

WITH_NVIDIA=0
[ "${1:-}" = "--nvidia" ] && WITH_NVIDIA=1

ARCH="$(dpkg --print-architecture)"

echo "== Install Docker =="
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo install -m 0755 -d /usr/share/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker
sudo docker --version
sudo usermod -aG docker "$USER"

echo "== Install QEMU =="
sudo apt-get install -y qemu-user-static binfmt-support
sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

if [ "$WITH_NVIDIA" -eq 1 ]; then
    # https://highreso.jp/edgehub/machinelearning/ubuntudocker.html#index_id7
    echo "== Install NVIDIA Container Toolkit =="
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
        | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
        | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    # no-cgroups = false に設定 (コメントアウトされていても対応)
    sudo sed -i -E 's/^#?\s*no-cgroups\s*=.*/no-cgroups = false/' /etc/nvidia-container-runtime/config.toml
    sudo systemctl restart docker
    echo "test: docker run -it --rm --runtime=nvidia --gpus all nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04 /bin/bash"
fi

echo "Done. docker グループ反映のため、再ログインしてください。"
