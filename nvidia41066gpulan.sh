#!/bin/bash

# nvidia41066gpulan.sh
# Michael McMahon
# This script installs proprietary NVIDIA drivers 410.66 and CUDA toolkit
# for GPU video output.

# To run this script, boot into your GNU/Linux distro with runlevel 2 or 3.
# Follow these instructions:
# Run this script with:
# sudo bash nvidia41066gpulan.sh
# OR
# su
# bash nvidia41066gpulan.sh
# OR
# sudo chmod 755 nvidia41066gpulan.sh
# sudo ./nvidia41066gpulan.sh
# OR
# su
# chmod 755 nvidia41066gpulan.sh
# ./nvidia41066gpulan.sh

# Prerequisites for this script:
#
# 0. On Supermicro boards, set the JPG1 pin to the 1-2 setting to enable the
#    BIOS to switch between Video Output modes.
#
#    In BIOS, change Advanced > PCIe/PCI/PnP Configuration > VGA Priority from
#    ```Onboard``` to ```Offboard```.
#
# 1. Install the system (with Compatibility Libraries and Development Tools or
# build-essential if applicable)
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
#  sudo apt update && sudo apt upgrade -y && sudo apt-get dist-upgrade -y
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
#  sudo bash nvidia41066.sh
#
# 6. Reboot and verify that all cards are working by running:
#  nvidia-smi
#
# If kernel headers are missing, install the kernel headers for your kernel.
#   Debian based systems: sudo apt install -y linux-headers-$(uname -r)
#   Red Hat based systems: yum install -y kernel-devel
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
  echo "This script must be run as root."
  exit 1
fi

# Check networking
# https://unix.stackexchange.com/questions/190513/
echo Checking network...
if ping -q -c 1 -W 1 google.com >/dev/null; then
  echo "The network is up."
else
  echo "The network is down."
  echo "Check connection and restart script!"
  exit 1
fi

if [[ $(runlevel | awk '{ print $2 }') -gt 3 ]]; then
  echo "Runlevel is greater than 3!"
  echo "Reboot and edit grub temporarily (press arrow keys up and down"
  echo "repeatedly during boot)"
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

# Downloading Installers
echo "Downloading proprietary NVIDIA drivers from local ftp..."
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/NVIDIA-Linux-x86_64-410.66.run
# wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/410.66/NVIDIA-Linux-x86_64-410.66.run

echo "Downloading proprietary CUDA toolkit from local ftp..."
date
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.0.176_384.81_linux.run
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.0.176.1_linux.run
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.0.176.2_linux.run
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.0.176.3_linux.run
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.0.176.4_linux.run
#wget -q http://developer2.download.nvidia.com/compute/cuda/9.0/secure/Prod/local_installers/cuda_9.0.176_384.81_linux.run
#wget -q http://developer.download.nvidia.com/compute/cuda/9.0/secure/Prod/patches/1/cuda_9.0.176.1_linux.run
#wget -q http://developer.download.nvidia.com/compute/cuda/9.0/secure/Prod/patches/2/cuda_9.0.176.2_linux.run
#wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.1.85_387.26_linux.run
#wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.1.85.1_linux.run
#wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.1.85.2_linux.run
#wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda/cuda_9.1.85.3_linux.run
# wget -q http://developer2.download.nvidia.com/compute/cuda/9.0/secure/Prod/local_installers/cuda_9.1.85_387.26_linux.run
# wget -q http://developer.download.nvidia.com/compute/cuda/9.1/secure/Prod/patches/1/cuda_9.1.85.1_linux.run
# wget -q http://developer.download.nvidia.com/compute/cuda/9.1/secure/Prod/patches/2/cuda_9.1.85.2_linux.run
# wget -q http://developer.download.nvidia.com/compute/cuda/9.1/secure/Prod/patches/3/cuda_9.1.85.3_linux.run
# wget -q https://developer.download.nvidia.com/compute/cuda/9.2/secure/Prod/local_installers/cuda_9.2.88_396.26_linux.run
# wget -q https://developer.download.nvidia.com/compute/cuda/9.2/secure/Prod/patches/1/cuda_9.2.88.1_linux.run
date


# Installing NVIDIA
# To learn more about the available switches, run:
#  sh NVIDIA-Linux-x86_64-XXX.XX.run -A | less

echo "Attempting to installing dkms..."
yum install -y epel-release 2>/dev/null
yum install -y dkms 2>/dev/null
yum install -y kernel-devel 2>/dev/null
dnf install -y dkms 2>/dev/null
apt-get update 2>/dev/null
apt-get install -y dkms 2>/dev/null

echo "Installing proprietary NVIDIA drivers..."
# If dkms is not installed, do not use the dkms switch.
if [[ $(which dkms | wc -l) -gt 0 ]]; then
  sh NVIDIA-Linux-x86_64-410.66.run --accept-license -q --dkms -X -Z --ui=none -s
else
  sh NVIDIA-Linux-x86_64-410.66.run --accept-license -q -X -Z --ui=none -s
  # sh NVIDIA-Linux-x86_64-410.66.run --accept-license -q -X -Z
fi
echo \ 

echo "Warnings about 32 bit libraries are OK."
echo "If any messages concern you, check the logs at"
echo "   /var/log/nvidia-installer.log"
echo \ 

# If RPM based distro 6.x, the NVIDIA installer will fail.  Use CTRL+C to close
# the installer.  Let the cuda install finish.  Manually run the NVIDIA
# installer.
#   sh NVIDIA-Linux-x86_64-410.66.run --accept-license -q -X

# To update NVIDIA drivers on a system that already has proprietary NVIDIA
# drivers, use:
# nvidia-installer --update


# Installing CUDA
# To learn more about the available switches, run:
#   sh cuda_X.X.XX_XXX.XX_linux-run --help

# Installing Cuda 9.0 instead of 9.1 for compatibility with TensorFlow.

echo "Installing proprietary CUDA toolkit..."
sh cuda_9.0.176_384.81_linux.run --toolkit --silent --override
#sh cuda_9.1.85_387.26_linux.run --toolkit --silent --override

# Installing CUDA patches
echo "Installing CUDA patches..."
sh cuda_9.0.176.1_linux.run --accept-eula -silent
sh cuda_9.0.176.2_linux.run --accept-eula -silent
sh cuda_9.0.176.3_linux.run --accept-eula -silent
sh cuda_9.0.176.4_linux.run --accept-eula -silent
#sh cuda_9.1.85.1_linux.run --accept-eula -silent
#sh cuda_9.1.85.2_linux.run --accept-eula -silent
#sh cuda_9.1.85.3_linux.run --accept-eula -silent

echo "Adding CUDA to the PATH..."
if [[ $(cat /etc/bashrc | grep cuda | wc -l) -eq 0 ]] && [ $(ls /etc/bashrc | wc -l) -gt 0 ]; then
  echo export 'PATH=/usr/local/cuda/bin:$PATH' >> /etc/bashrc
fi
if [[ $(cat /etc/bash.bashrc | grep cuda | wc -l) -eq 0 ]] && [ $(ls /etc/bash.bashrc | wc -l) -gt 0 ]; then
  echo export 'PATH=/usr/local/cuda/bin:$PATH' >> /etc/bash.bashrc
fi

echo "Adding CUDA libs to the ld.so.conf..."
if [[ $(cat /etc/default/grub | grep cuda | wc -l) -eq 0 ]]; then
  echo /usr/local/cuda/lib64 >> /etc/ld.so.conf
  echo /usr/local/cuda/lib >> /etc/ld.so.conf
fi

if [[ $(cat /etc/udev/rules.d/98-nvstusb.rules | wc -l) -eq 0 ]]; then
  echo "Creating udev rules for 3D Vision USB IR emitter..."
  echo "# NVIDIA 3D Vision USB IR Emitter" > /etc/udev/rules.d/98-nvstusb.rules
  echo "# From http://users.csc.calpoly.edu/~zwood/teaching/csc572/final11/rsomers/" >> /etc/udev/rules.d/98-nvstusb.rules
  echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}=="7003", MODE="0666"' >> /etc/udev/rules.d/98-nvstusb.rules
fi

echo "Blacklisting nouveau driver..."
if [[ $(cat /etc/modprobe.d/blacklist.conf | grep nouveau | wc -l) -eq 0 ]]; then
  echo blacklist nouveau >> /etc/modprobe.d/blacklist.conf
  echo blacklist lbm-nouveau >> /etc/modprobe.d/blacklist.conf
fi

echo "Executing dracut..."
dracut -f 2>/dev/null

echo "Executing ldconfig..."
ldconfig

if [[ $((lsb_release -a 2>/dev/null | grep -i Ubuntu | wc -l)) -gt 0 ]]; then
  echo "Updating initramfs for Ubuntu 17.10"
  rmmod nouveau
  update-initramfs -u
  update-grub
fi


# Log details
echo "All temporary installers, scripts, and logs can be found"
echo "in the /tmp/ folder."
uptime
echo "Log saved to $logfile"
echo \ 


# Post install check
echo "Running nvidia-smi..."
nvidia-smi
echo "If nvidia-smi fails to load or all of the video cards are not listed"
echo "above, the installer may have ran into a problem.  Check the"
echo "/var/log/nvidia-installer.log file for help and more details."
echo \ 
echo "Reboot and check nvidia-smi again to ensure the install succeeded."
echo \ 


# SBGrid 3D Workstation orders
echo "Systems with NVIDIA 3D Vision Glasses must also run:"
echo "  nvidia-xconfig --stereo=11"
echo \ 
