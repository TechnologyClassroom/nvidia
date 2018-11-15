#!/bin/bash

# nvidiafedora26-1.sh
# Michael McMahon
# This script prepares Fedora 25 or 26 for NVIDIA driver installation for GPU video output.
# This script does not install drivers.

# This script can be run from runlevel 5.

# Run this script with:
# su
# bash nvidiafedora26-1.sh



# Initialization checks

# Check for /bin/bash.
if [ "$BASH_VERSION" = '' ]; then
  echo "You are not using bash."
  echo "Use this syntax instead:"
  echo "sudo bash nvidia.sh"
  exit 1
fi

# Check for root.
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
fi

# Check networking
# https://unix.stackexchange.com/questions/190513/shell-scripting-proper-way-to-check-for-internet-connectivity
echo Checking network...
if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "The network is up."
else
  echo "The network is down."
  echo Check connection and restart script!
  exit 1
fi

# Log all stdout to logfile with date.
logfile=/tmp/$(date +%Y%m%d-%H%M).log
exec &> >(tee -a "$logfile")
echo Starting logfile as $logfile...
echo \ 


# https://www.if-not-true-then-false.com/2015/fedora-nvidia-guide/

# Update system
echo "Updating the system..."
dnf update -y

# Install packages
echo "Installing dependencies with dnf..."
dnf install -y kernel-devel kernel-headers gcc dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig

# Blacklist nouveau
echo "Blacklisting nouveau..."
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf

# Add string to grub
echo "Adding a string to grub..."
sed -i 's/.*LINUX=.*/GRUB_CMDLINE_LINUX="rd.lvm.lv=fedora\/swap rd.lvm.lv=fedora\/root rhgb quiet rd.driver.blacklist=nouveau"/' /etc/sysconfig/grub

# Overwrite grub with changes
echo "Updating grub..."
## BIOS ##
grub2-mkconfig -o /boot/grub2/grub.cfg
## UEFI ##
#grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# Remove nouveau
echo "Uninstalling nouveau..."
dnf remove xorg-x11-drv-nouveau

# Remove exclude=xorg-x11* line from dnf.conf
echo "Removing xorg line from dnf.conf..."
sed -i 's/.*clude=xorg.*//' /etc/dnf/dnf.conf

# Dracut without nouveau
echo "Executing dracut..."
mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
dracut /boot/initramfs-$(uname -r).img $(uname -r)

# Runlevel 3
echo "Changing system to runlevel 3..."
systemctl set-default multi-user.target

# Reboot
echo "Rebooting..."
reboot

