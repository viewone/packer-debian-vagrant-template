# Vagrant specific
date > /etc/vagrant_box_build_time

# Setup sudo to allow no-password sudo for "admin"
echo "Create admin group and add vagrant user to this group"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e '/%sudo\s\+ALL=(ALL:ALL)\s\+ALL/a%admin\tALL=NOPASSWD:ALL' /etc/sudoers
rm /etc/sudoers.orig

# Installing vagrant keys
mkdir -pm 700 /home/vagrant/.ssh
echo "Importing vagrant public key into authorized_keys..."
wget -q ${WGET_OPTIONS} --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys || \
    { "Failed to download vagrant public key."; exit 1; }
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Customize the message of the day
# echo 'Welcome to your Vagrant-built virtual machine.' > /etc/motd