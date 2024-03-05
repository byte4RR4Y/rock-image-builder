#! /bin/bash

if [ "$UID" -ne 0 ]; then 
    echo "This program needs sudo rights."
    echo "Run it with 'sudo $0'"
    exit 1
fi

apt update -y && apt install -y git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64 docker.io apparmor qemu-user-static binfmt-support qemu-user qemu-system qemu-utils xfce4-terminal qemu-system-aarch64 u-boot-qemu golang swtpm qemu-system-gui
chmod +x ./*
chmod +x config/*

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
 
