# nvidia

Wrapper scripts to install proprietary NVIDIA drivers on GNU/Linux systems.

Michael McMahon

The process for installing proprietary NVIDIA drivers is unnecessarily
complicated across different GNU/Linux operating systems.  These scripts make
complex installs easier.

Format: ```nvidia (Version) (Video Output)```

Variations:

- cudaburnin.sh runs gpu_burn for one hour.  This requires one of the other
  nvidiaXXX scripts to be run first.
- nvidiaXXX.XXgpu.sh installs NVIDIA drivers and cuda for standard video
  output from the GPU.
- nvidiaXXX.XXmb.sh installs NVIDIA drivers and cuda for non-standard video
  output from the motherboard.  This is only useful if you have to use VGA
  output for IPMI remote management.  cuda performance takes a small hit.  This
  is not recommended.
- nvidiaXXX.XXAAAlan.sh installs from a local FTP server.
- nvidiafedora26-1.sh DISCONTINUED
- nvidiafedora26-2.sh DISCONTINUED
- nvidianew.sh is an unfinished development version for full automation.  (Help
  wanted)

Compatible operating systems:

- CentOS 6
- CentOS 7
- Debian 8
- Debian 9
- RHEL 6
- RHEL 7
- Scientific Linux 6
- Scientific Linux 7
- Ubuntu 14.04 Desktop
- Ubuntu 14.04 Server
- Ubuntu 16.04 Desktop
- Ubuntu 16.04 Server
- Ubuntu 17.10 Desktop
- Ubuntu 17.04 Server

By using these scripts, you agree to all EULAs presented by NVIDIA.

## Prerequisites

Prerequisites for this script:

0. Disable secure boot.  On supermicro boards, change the JPG1 pin to the
   setting that you want.to the 2-3 setting for GPU video output.
1. Install the system (with Compatibility Libraries and Development Tools or
   build-essential if applicable).
2. Update all software.
   - CentOS / Scientific Linux

   ```
   su
   yum update -y
   ```

   - Fedora
   ```dnf -y update```

   - Debian based systems

   ```
   sudo apt update
   sudo apt upgrade -y
   sudo apt-get dist-upgrade -y
   ```

3. Install Compatibility Libraries and Development Tools or build-essential
   - CentOS / Scientific Linux 6

   ```
   yum groupinstall -y Development\ Tools
   yum groupinstall -y Compatibility\ Libraries
   ```

   - CentOS / Scientific Linux 7

   ```
   yum groups install -y Development\ Tools
   yum groups install -y Compatibility\ Libraries
   ```

   - Debian based systems

   ```
   sudo apt-get install -y ledmon build-essential
   ```

4. Boot into the correct runlevel with ```nomodeset rdblacklist nouveau```.
   - Reboot and edit grub temporarily (press arrow keys up and down repeatedly
     during boot)
   - Press `e` on the top entry to edit temporarily.  Edit the line that starts
     with linux.  Add these entries around words like 'ro quiet':
     ```nomodeset rdblacklist nouveau 3```
   - Note: Ubuntu Desktop requires editing /etc/default/grub and running
     ```update-grub``` or backing up and editing /boot/grub/grub.cfg with:
     ```nomodeset rdblacklist nouveau 2 text```

## Running the script

To run these scripts:

- Boot into your GNU/Linux distro with runlevel 2 or 3.
- Login as root.
- ```bash nvidia39025gpu.sh```
- ```reboot```
- After rebooting, run ```nvidia-smi``` again to ensure the install succeeded.

## Troubleshooting

- If nvidia-smi fails to load or all of the video cards are not listed, the
  installer may have ran into a problem.  Check the
  /var/log/nvidia-installer.log file for help and more details.  If you cannot
  solve the problem, contact
  [NVIDIA support](http://www.nvidia.com/object/support.html).
- Warnings about missing 32 bit libraries are OK on 64 bit systems.
- If secure boot is enabled, you may see "ERROR: Unable to load the kernel
  module 'nvidia.ko'.  This happens most frequently when this kernel module was
  built against hte wrong or improperly configured kernel sources."
- These scripts will need to be reinstalled with each kernel update if DKMS is
  not used.
- If gcc is missing, follow the prerequisites section and install Development
  Tools or build-essential metapackages.
- If kernel headers are missing, install the kernel headers for your kernel.

  Debian based systems: ```sudo apt install -y linux-headers-$(uname -r)```

  Red Hat based systems: ```yum install -y kernel-devel```
