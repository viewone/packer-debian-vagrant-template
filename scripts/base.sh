# Update and install essential packages
echo "Installing essential packages"
sudo apt-get update
sudo apt-get install -y linux-headers-$(uname -r) build-essential dkms