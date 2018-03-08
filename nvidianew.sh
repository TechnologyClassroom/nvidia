#!/bin/bash

# nvidia38490gpu.sh
# Michael McMahon
# This script installs proprietary NVIDIA drivers 384.98 and CUDA toolkit
# for GPU video output.

## Instructions:
# Run this script with:
# sudo bash nvidia38469gpu.sh
# OR
# su
# bash nvidia38469gpu.sh
# OR
# sudo chmod 755 nvidia38469gpu.sh
# sudo ./nvidia38469gpu.sh
# OR
# su
# chmod 755 nvidia38469gpu.sh
# ./nvidia38469gpu.sh

# Prerequisites for this script:
#
# 0. Change the JPG1 pin to the 2-3 setting for GPU video output.
#   To disable vga on supermicro boards, the JPG1 pins should be set to 2-3.
#
# 5. Run this script as root.
#  bash nvidianew.sh
#  OR
#  sudo bash nvidianew.sh
#
# 6. Verify that all cards are working by running:
#  nvidia-smi
#



# Initialization checks

# Check for /bin/bash.
if [ "$BASH_VERSION" = '' ]; then
  echo "You are not using bash."
  echo "Use this syntax instead:"
  echo "bash nvidia.sh"
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
  echo "Check connection and restart script!"
  exit 1
fi

if [[ $(runlevel | awk '{ print $2 }') -gt 3 ]]; then
  echo "Runlevel is greater than 3"
  echo "Reboot and edit grub temporarily (press arrow keys up and down repeatedly during boot)"
  echo "Press 'e' on the top entry to edit temporarily.  Edit the line that starts with linux.  Add these entries around words like 'ro quiet':"
  echo "nomodeset rdblacklist nouveau 3"

  echo "Creating boot hook..."
#  cat << EOF > /etc/systemd/system/nvidiainstall.service
#[Unit]
#Description=Temporary script to install proprietary NVIDIA drivers
#After=network.target

#[Service]
#ExecStart=/usr/local/bin/disk-space-check.sh
#ExecStart=/etc/init.d/nvidiagpuinstall_once

#[Install]
#WantedBy=default.target

#EOF

  cat << EOF > /etc/init.d/nvidiagpuinstall_once
#!/bin/bash

# NVIDIA install hook
# Located at /etc/init.d/nvidiagpuinstall_once
# Symlinked from /etc/rc3.d/S01nvidiagpuinstall

### BEGIN INIT INFO
# Provides:          nvidiagpuinstall_once
# Required-Start:
# Required-Stop:
# Default-Start: 3
# Default-Stop:
# Short-Description: Install proprietary NVIDIA drivers during runlevel 3
# Description:
### END INIT INFO


# Log all stdout to logfile with date.
logfile=/tmp/$(date +%Y%m%d-%H%M).log
exec &> >(tee -a "$logfile")
echo Starting logfile as $logfile...
echo \ 



echo "Temporarily removing nouvea..."
modprobe -r nouveau
# DEBUG # nouveau continues to run with Scientific Linux 7

echo "Changing into the /tmp directory..."
cd /tmp



echo "This script currently works with GPU video output for"
echo "RPM or DEB workflows after you have properly booted."

# Downloading
echo "Downloading proprietary NVIDIA drivers..."
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/384.98/NVIDIA-Linux-x86_64-384.98.run
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/NVIDIA-Linux-x86_64-384.98.run
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/384.90/NVIDIA-Linux-x86_64-384.90.run
#wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/NVIDIA-Linux-x86_64-384.90.run
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/384.69/NVIDIA-Linux-x86_64-384.69.run
#wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/NVIDIA-Linux-x86_64-384.69.run

# Experimental automatically download latest stable driver
#wget http://www.nvidia.com/object/unix.html
#cat unix.html | grep "Latest Long Lived Branch version" | head -n 1 | cut -d '"' -f2 | xargs wget
#cat en-us | grep "confirmation.php" | cut -d '"' -f2 | awk '{print "http://www.nvidia.com" $1}' | xargs wget
#cat confirmatio* | grep .run | head -n 1 | cut -d '"' -f2 | xargs wget
# Works!

echo "Downloading proprietary CUDA toolkit..."
date
#wget -q http://developer2.download.nvidia.com/compute/cuda/9.0/secure/Prod/local_installers/cuda_9.0.176_384.81_linux.run
wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda_9.0.176_384.81_linux.run
#wget -q https://developer.nvidia.com/compute/cuda/8.0/prod2/local_installers/cuda_8.0.61_375.26_linux-run
#wget -q https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run
#wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda_8.0.61_375.26_linux-run
#wget -q https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/cuda_8.0.61.2_linux-run
#wget -q ftp://10.12.17.15/pub/software/drivers/nvidia/cuda_8.0.61.2_linux-run
date



# Installing NVIDIA
# To learn more about the available switches, see http://www.manpages.spotlynx.com/gnu_linux/man/nvidia-installer.1 or run:
#  sh NVIDIA-Linux-x86_64-XXX.XX.run --help

echo "Installing proprietary NVIDIA drivers..."
#sh NVIDIA-Linux-x86_64-384.98.run --accept-license -q -X -Z
sh NVIDIA-Linux-x86_64-384.98.run --accept-license -q -X -Z --ui=none -s
#sh NVIDIA-Linux-x86_64-384.90.run --accept-license -q -X -Z
#sh NVIDIA-Linux-x86_64-384.90.run --accept-license -q -X -Z --ui=none -s

# If RPM based distro 6.x, the NVIDIA installer will fail.  Use CTRL+C to close the installer.  Let the cuda install finish.  Manually run the NVIDIA installer.
#  sh NVIDIA-Linux-x86_64-384.69.run --accept-license -q -X

# To update NVIDIA drivers on a system that already has proprietary NVIDIA drivers, use:
# nvidia-installer --update



# Installing CUDA
# To learn more about the available switches, run:
#   sh cuda_* --help

echo "Installing proprietary CUDA toolkit..."
sh cuda_9.0.176_384.81_linux.run --toolkit -silent --override

echo "Adding CUDA to the PATH..."
if [[ $(cat /etc/bashrc | grep cuda | wc -l) -eq 0 ]]; then
  echo export 'PATH=/usr/local/cuda/bin:$PATH' >> /etc/bashrc
fi

echo "Adding CUDA libs to the ld.so.conf..."
if [[ $(cat /etc/default/grub | grep cuda | wc -l) -eq 0 ]]; then
  echo /usr/local/cuda/lib64 >> /etc/ld.so.conf
  echo /usr/local/cuda/lib >> /etc/ld.so.conf
fi

echo "Blacklisting nouveau driver..."
if [[ $(cat /etc/modprobe.d/blacklist.conf | grep nouveau | wc -l) -eq 0 ]]; then
  echo blacklist nouveau >> /etc/modprobe.d/blacklist.conf
fi

echo "(Red Hat) Executing dracut..."
dracut -f 2>/dev/null

echo "(OpenSUSE) Executing mkinitrd..."
mkinitrd 2>/dev/null

echo "Executing ldconfig..."
ldconfig



# Log details
echo "All temporary installers, scripts, and logs can be found in the /tmp/ folder."
uptime
echo "Log saved to $logfile"
echo \ 



# Remove hooks
rm -f /etc/init.d/nvidiagpuinstall_once
rm -f /etc/rc3.d/S01nvidiagpuinstall
#rm -f /etc/systemd/system/nvidiainstall.service
crontab -u root -l | grep -v 'nvidiagpuinstall' | crontab -u root -

# Remove files
#rm -f /tmp/NVIDIA-Linux-*
#rm -f /tmp/nvidia*.sh
#rm -f /tmp/cuda_*

# SBGrid 3D Workstation orders
echo "Systems with NVIDIA 3D Vision Glasses must also run:"
echo "  nvidia-xconfig --stereo=11"
echo \ 

if [[ $(ls /etc/sysconfig/grub 2>/dev/null | wc -l) -gt 0 ]]; then
  sed -i 's/.*CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="rhgb quiet"/' /etc/sysconfig/grub
  sed -i 's/.*CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="rhgb quiet"/' /etc/default/grub
  # This is from minimal.  Default CentOS and rhel may vary.
  ## BIOS ##
  grub2-mkconfig -o /boot/grub2/grub.cfg
  ## UEFI ##
  #grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  #systemctl set-default graphical.target
  /sbin/reboot
  exit 1
fi

if [[ $(ls /etc/default/grub 2>/dev/null | wc -l) -gt 0 ]]; then
  sed -i 's/.*LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub
  update-grub
  #systemctl set-default graphical.target
  /sbin/reboot
  exit 1
fi

EOF

  echo "Making the script executable..."
  chmod 744 /etc/init.d/nvidiagpuinstall_once
  echo -e "$(sudo crontab -u root -l)\n@reboot /etc/init.d/nvidiagpuinstall_once" | crontab -u root -
  #chmod 664 /etc/systemd/system/nvidiainstall.service
  #systemctl daemon-reload
  #systemctl enable nvidiainstall.service

  # Hook does not work on CentOS 7.  Seems to work on Scientific Linux.

  echo "Creating symlink..."
  ln -s /etc/init.d/nvidiagpuinstall_once /etc/rc3.d/S01nvidiagpuinstall

  # OpenSUSE
  zypper install -t pattern devel_C_C++ devel_kernel 2>/dev/null


  echo "Blacklisting nouveau driver..."
  if [[ $(cat /etc/modprobe.d/blacklist.conf | grep nouveau | wc -l) -eq 0 ]]; then
    echo blacklist nouveau >> /etc/modprobe.d/blacklist.conf
  fi

  if [[ $(ls /etc/sysconfig/grub 2>/dev/null | wc -l) -gt 0 ]]; then
    echo "Updating system..."
    yum update -y 2>/dev/null
    yum groupinstall -y Development\ Tools 2>/dev/null
    yum groupinstall -y Compatibility\ Libraries 2>/dev/null
    yum groups install -y Development\ Tools 2>/dev/null
    yum groups install -y Compatibility\ Libraries 2>/dev/null
    dnf -y update 2>/dev/null

    echo "Modifying grub for NVIDIA install..."
    sed -i 's/.*CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="rhgb rdblacklist nouveau nomodeset 2"/' /etc/sysconfig/grub
    sed -i 's/.*CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="rhgb rdblacklist nouveau nomodeset 2"/' /etc/default/grub
    ## BIOS ##
    grub2-mkconfig -o /boot/grub2/grub.cfg
    ## UEFI ##
    #grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    #systemctl set-default multi-user.target
    reboot
    exit 1
  fi

  if [[ $(ls /etc/default/grub 2>/dev/null | wc -l) -gt 0 ]]; then
    echo "Updating system..."
    apt update 2>/dev/null
    apt upgrade -y 2>/dev/null
    apt-get dist-upgrade -y  2>/dev/null
    apt install -y ledmon 2>/dev/null
    apt install -y build-essential 2>/dev/null

    echo "Modifying grub for NVIDIA install..."
    sed -i 's/.*LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="rdblacklist nouveau nomodeset text 2"/' /etc/default/grub
    update-grub
    #systemctl set-default multi-user.target
    reboot
    exit 1
  fi

fi
