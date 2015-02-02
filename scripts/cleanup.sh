#!/bin/bash -eux

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "==> Cleaning up udev rules"
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "==> Cleaning up leftover dhcp leases"
if [ -d "/var/lib/dhcp" ]; then
    rm /var/lib/dhcp/*
fi

echo "==> Cleaning up packages"

# Clean up packages which was needed for virtualbox guest additions
apt-get -y --purge remove linux-headers-$(uname -r) build-essential dkms

# Clean up config files
apt-get -y purge $(dpkg --list | grep '^rcb' | awk '{ print $2 }')

# Clean up linux images and header without current
apt-get -y purge $(dpkg -l linux-* | awk '/^ii/{ print $2}' | grep -v -e `uname -r | cut -f1,2 -d"-"` | grep -e [0-9] | grep -E "(image|headers)")

apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean

echo "==> Cleaning up tmp"
rm -rf /tmp/*

# Remove Bash history
echo "==> Cleaning up bash history"
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Clean up log files
echo "==> Cleaning up logs"
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# Clean up cache
echo "==> Cleaning up cache"
find /var/cache -type f -delete -print

# Clean virtualbox src
echo "==> Cleaning up virtualbox guest additions src"
rm /home/vagrant/VBoxGuestAdditions.iso
rm -rf /usr/src/virtualbox-ose-guest*
rm -rf /usr/src/vboxguest*

# Whiteout root
echo "==> Whiteout root"
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
rm /tmp/whitespace

# Whiteout /boot
echo "==> Whiteout boot"
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count
rm /boot/whitespace

# Zero out the free space to save space in the final image
echo "==> Zero out the free space"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early
sync