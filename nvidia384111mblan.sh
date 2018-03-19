#!/bin/bash

# nvidia384111mblan.sh
# Michael McMahon
# This script installs proprietary NVIDIA drivers 384.111 and CUDA toolkit
# for motherboard video output.

# To run this script, boot into your GNU/Linux distro with runlevel 2 or 3.
# Follow these instructions:
# Run this script with:
# sudo bash nvidia384111mblan.sh
# OR
# su
# bash nvidia384111mblan.sh
# OR
# sudo chmod 755 nvidia384111mblan.sh
# sudo ./nvidia384111mblan.sh
# OR
# su
# chmod 755 nvidia384111mblan.sh
# ./nvidia384111mblan.sh

# Prerequisites for this script:
#
# 0. Change the JPG1 pin to the 2-3 setting for GPU video output.
#   To disable vga on supermicro boards, the JPG1 pins should be set to 2-3.
#
# 1. Install the system (with Compatibility Libraries and Development Tools if applicable)
#
# 2. Update all software
#  # CentOS / Scientific Linux
#  su
#  yum update -y
#
#  # Fedora
#  dnf -y update
#
#  # Debian based systems
#  sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y 
#
# 3. Install Compatibility Libraries and Development Tools or build-essential
#  # CentOS / Scientific Linux 6
#  yum groupinstall -y Development\ Tools
#  yum groupinstall -y Compatibility\ Libraries
#
#  # CentOS / Scientific Linux 7
#  yum groups install -y Development\ Tools
#  yum groups install -y Compatibility\ Libraries
#
#  # Debian based systems
#  sudo apt-get install -y ledmon build-essential
#
# 4. Boot into the correct runlevel with nomodeset rdblacklist nouveau
#  Reboot and edit grub temporarily (press arrow keys
#  up and down repeatedly during boot)
#  Press 'e' on the top entry to edit temporarily.  Edit the line that starts
#  with linux.  Add these entries around words like 'ro quiet':
#    nomodeset rdblacklist nouveau 3
#  Note: Ubuntu Desktop requires editing /etc/default/grub and running
#  update-grub or backing up and editing /boot/grub/grub.cfg with:
#    nomodeset rdblacklist nouveau 2 text
#
# 5. Run this script.
#  sudo bash nvidia384111.sh
#
# 6. Reboot and verify that all cards are working by running:
#  nvidia-smi
#



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

if [[ $(runlevel | awk '{ print $2 }') -gt 3 ]]; then
  echo "Runlevel is greater than 3"
  echo "Reboot and edit grub temporarily (press arrow keys up and down repeatedly during boot)"
  echo "Press 'e' on the top entry to edit temporarily.  Edit the line that"
  echo "starts with linux.  Add these entries around words like 'ro quiet':"
  echo "  nomodeset rdblacklist nouveau 3"
  
  exit 1
fi

# Log all stdout to logfile with date.
logfile=/tmp/$(date +%Y%m%d-%H%M).log
exec &> >(tee -a "$logfile")
echo Starting logfile as $logfile...
echo \ 



echo "Temporarily removing nouvea..."
modprobe -r nouveau

echo "Changing into the /tmp directory..."
cd /tmp



echo "This script currently works with GPU video output for"
echo "RPM or DEB workflows after you have properly booted."

# Downloading
echo "Downloading proprietary NVIDIA drivers..."
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/NVIDIA-Linux-x86_64-384.111.run
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/384.111/NVIDIA-Linux-x86_64-384.111.run
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/384.90/NVIDIA-Linux-x86_64-384.90.run
#wget -q ftp://10.12.17.15/pub/utility/nvidia/NVIDIA-Linux-x86_64-384.90.run
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/384.111/NVIDIA-Linux-x86_64-384.111.run
#wget -q ftp://10.12.17.15/pub/utility/nvidia/NVIDIA-Linux-x86_64-384.111.run

echo "Downloading proprietary CUDA toolkit..."
date
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.1.85_387.26_linux.run
#wget -q http://developer2.download.nvidia.com/compute/cuda/9.0/secure/Prod/local_installers/cuda_9.1.85_387.26_linux.run
#wget -q http://developer2.download.nvidia.com/compute/cuda/9.0/secure/Prod/local_installers/cuda_9.0.176_384.81_linux.run
#wget -q ftp://10.12.17.15/pub/utility/nvidia/cuda_9.0.176_384.81_linux.run
#wget -q https://developer.nvidia.com/compute/cuda/8.0/prod2/local_installers/cuda_8.0.61_375.26_linux-run
#wget -q https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run
#wget -q ftp://10.12.17.15/pub/utility/nvidia/cuda_8.0.61_375.26_linux-run
#wget -q https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/cuda_8.0.61.2_linux-run
#wget -q ftp://10.12.17.15/pub/utility/nvidia/cuda_8.0.61.2_linux-run
date



# Installing NVIDIA
# To learn more about the available switches, see http://www.manpages.spotlynx.com/gnu_linux/man/nvidia-installer.1 or run:
#  sh NVIDIA-Linux-x86_64-XXX.XX.run --help

echo "Installing proprietary NVIDIA drivers..."

echo "Attempting to installing dkms..."
yum install -y epel-release 2>/dev/null
yum install -y dkms 2>/dev/null
yum install -y kernel-devel 2>/dev/null
dnf install -y dkms 2>/dev/null
apt-get update 2>/dev/null
apt-get install -y dkms 2>/dev/null

echo "Installing NVIDIA drivers..."
# If dkms is not installed, do not use the dkms switch.
if [[ $(which dkms | wc -l) -gt 0 ]]; then
  sh NVIDIA-Linux-x86_64-384.111.run --accept-license -q --dkms --no-opengl-files
else
  sh NVIDIA-Linux-x86_64-384.111.run --accept-license -q --no-opengl-files
fi

# If RPM based distro 6.x, the NVIDIA installer will fail.  Use CTRL+C to close the installer.  Let the cuda install finish.  Manually run the NVIDIA installer.
#  sh NVIDIA-Linux-x86_64-384.111.run --accept-license -q -X

# To update NVIDIA drivers on a system that already has proprietary NVIDIA
# drivers, use:
# nvidia-installer --update



# Installing CUDA
# To learn more about the available switches, run:
#   sh cuda_8.0.61_375.26_linux-run --help

echo "Installing proprietary CUDA toolkit..."
sh cuda_9.1.85_387.26_linux.run --toolkit --silent --override
#sh cuda_9.0.176_384.81_linux.run --toolkit --silent --override

echo "Adding CUDA to the PATH..."
echo export 'PATH=/usr/local/cuda/bin:$PATH' >> /etc/bashrc

echo "Adding CUDA libs to the ld.so.conf..."
echo /usr/local/cuda/lib64 >> /etc/ld.so.conf
echo /usr/local/cuda/lib >> /etc/ld.so.conf

echo "Blacklisting nouveau driver..."
echo blacklist nouveau >> /etc/modprobe.d/blacklist.conf

echo "Executing dracut..."
dracut -f 2>/dev/null

echo "Executing ldconfig..."
ldconfig



# Log details
echo "All temporary installers, scripts, and logs can be found"
echo "in the /tmp/ folder."
uptime
echo "Log saved to $logfile"
echo \ 



# Post install check
echo "Running nvidia-smi..."
nvidia-smi
echo "If all of the video cards are not listed above, the installer ran into"
echo "a problem.  Check the /var/log/nvidia-installer.log file for help."
echo \ 
echo "Reboot and check nvidia-smi again to ensure the install succeeded."



# SBGrid 3D Workstation orders
echo "Systems with NVIDIA 3D Vision Glasses must also run:"
echo "  nvidia-xconfig --stereo=11"
echo \ 
