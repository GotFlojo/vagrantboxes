#!/usr/bin/env bash
set -e

if [ "$EUID" -ne "0" ] ; then
        echo "Script must be run as root." >&2
        exit 1
fi

if which ansible > /dev/null ; then
        echo "ansible is already installed"
        exit 0
fi

# Sort pacman mirrors by speed and use the 6 fastest ones
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
echo "Searching fastest mirrors. This might take a while"
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
# Alternatively we can pull a list for Germany from here:
# https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on
# wget -O /etc/pacman.d/mirrorlist https://www.archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on

echo "Updating package list"
pacman -Sy
echo "Installing ansible"
pacman -S --noconfirm ansible
echo "ansible installed!"
echo "Running ansible"
cd /vagrant
ansible-playbook -i hosts site.yml
