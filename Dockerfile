arg ARCH_LINUX_VERSION=latest
from archlinux:${ARCH_LINUX_VERSION}
shell ["/bin/bash", "-c"]
run pacman -Syu --noconfirm && pacman -S --noconfirm git neovim sudo python python-pip make
run echo 'docker ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
run groupadd -r docker && sudo useradd -r -g docker docker -m && passwd -d docker
user docker
workdir /home/docker
run mkdir -p /home/docker/.config/nvim
copy ./custom_init.lua /home/docker/.config/nvim/init.lua
run git clone https://github.com/matthejue/PicoC-Compiler.git -b missing_semester_project --depth 1 && cd PicoC-Compiler && python -m venv .virtualenv && source .virtualenv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt && sudo make install
