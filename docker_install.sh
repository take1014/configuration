# install docker
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo docker --version
sudo usermod -aG docker $USER

# install qemu
sudo apt update
sudo apt install qemu-user-static binfmt-support 
sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# install nvidia docker
# https://highreso.jp/edgehub/machinelearning/ubuntudocker.html#index_id7
# set gpg key
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# install nvidia container toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
# set docker daemon
sudo nvidia-ctk runtime configure --runtime=docker
sudo vim /etc/nvidia-container-runtime/config.toml
# set no-cgroups=false
sudo systemctl restart docker
# test nvidia docker container
docker run -it --rm --runtime=nvidia --gpus all nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04 /bin/bash
