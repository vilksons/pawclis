#!/bin/bash

### What dependencies are installed? Please see: https://github.com/vilksons/pawnclis/wiki/Required-Library

set -e

LOG_FILE="install_log.txt"
exec > >(tee -i $LOG_FILE) 2>&1

if [[ -f /etc/os-release ]]; then
    $SUDO . /etc/os-release
    OS=$ID
else
    echo "Unsupported OS"
    bash -
fi

if ! command -v sudo &> /dev/null; then
    echo "sudo not found. Attempting to install..."
    if [[ "$OS" == "arch" || "$OS" == "manjaro" ]]; then
        su -c "pacman -Sy --noconfirm sudo"
    elif [[ "$OS" == "debian" || "$OS" == "ubuntu" || "$OS" == "devuan" ]]; then
        su -c "apt update && apt install -y sudo"
    elif [[ "$OS" == "fedora" || "$OS" == "rhel" || "$OS" == "centos" ]]; then
        su -c "dnf install -y sudo"
    elif [[ "$OS" == "alpine" ]]; then
        su -c "apk add sudo"
    elif [[ "$OS" == "void" ]]; then
        su -c "xbps-install -Sy sudo"
    else
        echo "Cannot install sudo automatically. Please install it manually."
        bash -
    fi
fi

ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    LIB_STD="libstdc++"
    LIB_GLIBC="lib32-glibc"
elif [[ "$ARCH" == "i386" || "$ARCH" == "i686" ]]; then
    LIB_STD="libstdc++"
    LIB_GLIBC="glibc"
else
    echo "Unsupported architecture: $ARCH"
    bash -
fi

case "$OS" in
    debian|ubuntu|ubuntu_kylin|elementary|devuan|kali|trisquel|pop|deepin|steamos|zorin|linuxmint)
        $SUDO dpkg --add-architecture i386
        $SUDO apt install -y curl python3 python3-pip "$LIB_STD":i386
        ;;
    arch|arch32|blackarch|arcolinux|archcraft|garuda|manjaro)
        $SUDO pacman -S --noconfirm curl python python-pip "$LIB_GLIBC"
        ;;
    opensuse*|suse*)
        $SUDO zypper refresh && $SUDO zypper install -y curl python3 python3-pip "$LIB_STD"
        ;;
    rhel|centos|centos_stream|fedora|rocky|almalinux)
        $SUDO dnf install -y curl python3 python3-pip "$LIB_STD"
        ;;
    alpine)
        $SUDO apk update && $SUDO apk add curl python3 py3-pip "$LIB_STD"
        ;;
    gentoo)
        $SUDO emerge --sync && $SUDO emerge --ask dev-lang/python net-misc/curl sys-libs/glibc
        ;;
    void)
        $SUDO xbps-install -Sy curl python3 python3-pip "$LIB_STD"
        ;;
    slackware)
        $SUDO slackpkg update && $SUDO slackpkg install curl python3 pip "$LIB_STD"
        ;;
    nixos)
        $SUDO nix-env -iA nixpkgs.curl nixpkgs.python3 nixpkgs.python3Packages.pip nixpkgs.glibc nixpkgs.libstdcxx
        ;;
    *)
        echo "Unsupported distribution: $OS"
        bash -
        ;;
esac

pip3 install --upgrade requests urllib3 pycurl

curl -L -o pawnclis https://raw.githubusercontent.com/vilksons/pawnclis/refs/heads/main/Scripts/pawnclis

chmod +x pawnclis

echo "Installation completed successfully. Log file: $LOG_FILE"

bash ./pawnclis

read -r -p "end..."
