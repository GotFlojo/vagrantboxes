#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

if [ ! -s /etc/pacman.d/mirrorlist.backup ]; then
    # Sort pacman mirrors by speed and use the 6 fastest ones
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
    # remove last 3 line from pacman.conf as these contain a hardcoded mirror
    if [ ! -s /etc/pacman.conf.backup ]; then
        cp /etc/pacman.conf /etc/pacman.conf.backup
        head -n -3 /etc/pacman.conf.backup > /etc/pacman.conf
    fi
    echo "Searching fastest mirrors. This might take a while"
    rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
    # Alternatively we can pull a list for Germany from here:
    # https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on
    # wget -O /etc/pacman.d/mirrorlist https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on
fi
echo "Updating package list"
pacman -Sy
if which ansible > /dev/null ; then
        echo "ansible is already installed"
else
        echo "Installing ansible"
        pacman -S --noconfirm ansible
        echo "ansible installed!"
fi

echo "Running ansible"
cd /vagrant
ansible-playbook -i hosts site.yml
