#!/bin/bash

# nvidia38469gpu.sh
# Michael McMahon
# This script installs proprietary NVIDIA drivers 384.69 and CUDA toolkit for GPU video output.

# Run this script with:
# sudo bash nvidia38469gpu.sh


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
  echo "Press 'e' on the top entry to edit temporarily.  Edit the line that starts with linux.  Add these entries around words like 'ro quiet':"
  echo "nomodeset rdblacklist nouveau 3"
  
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

# Downloading
echo "Downloading proprietary NVIDIA drivers..."
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/384.90/NVIDIA-Linux-x86_64-384.90.run
wget -q ftp://10.12.17.15/pub/utility/nvidia/NVIDIA-Linux-x86_64-384.90.run
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/384.69/NVIDIA-Linux-x86_64-384.69.run
#wget -q ftp://10.12.17.15/pub/utility/nvidia/NVIDIA-Linux-x86_64-384.69.run

echo "Downloading proprietary CUDA toolkit..."
date
#wget -q http://developer2.download.nvidia.com/compute/cuda/9.0/secure/Prod/local_installers/cuda_9.0.176_384.81_linux.run
wget -q ftp://10.12.17.15/pub/utility/nvidia/cuda_9.0.176_384.81_linux.run
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
sh NVIDIA-Linux-x86_64-384.90.run --accept-license -q -X --dkms -Z 

# If RPM based distro 6.x, the NVIDIA installer will fail.  Use CTRL+C to close the installer.  Let the cuda install finish.  Manually run the NVIDIA installer.
#  sh NVIDIA-Linux-x86_64-384.69.run --accept-license -q -X

# To update NVIDIA drivers on a system that already has proprietary NVIDIA drivers, use:
# nvidia-installer --update



# Installing CUDA
# To learn more about the available switches, run:
#   sh cuda_8.0.61_375.26_linux-run --help

echo "Installing proprietary CUDA toolkit..."
sh cuda_9.0.176_384.81_linux.run --toolkit -silent --override

echo "Adding CUDA to the PATH..."
echo export 'PATH=/usr/local/cuda/bin:$PATH' >> /etc/bashrc

echo "Adding CUDA libs to the ld.so.conf..."
echo /usr/local/cuda/lib64 >> /etc/ld.so.conf
echo /usr/local/cuda/lib >> /etc/ld.so.conf

#echo "Blacklisting nouveau driver..."
#echo blacklist nouveau >> /etc/modprobe.d/blacklist.conf

echo "Executing dracut..."
dracut -f 2>/dev/null

echo "Executing ldconfig..."
ldconfig



# Log details
echo "All temporary installers, scripts, and logs can be found in the /tmp/ folder."
uptime
echo "Log saved to $logfile"
echo \ 



# SBGrid 3D Workstation orders
echo "Systems with NVIDIA 3D Vision Glasses must also run:"
echo "  nvidia-xconfig --stereo=11"
echo \

echo "Returning runlevel to 5..."
systemctl set-default graphical.target

echo "Rebooting..."
reboot

