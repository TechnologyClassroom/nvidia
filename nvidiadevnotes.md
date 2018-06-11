# nvidia installer dev notes

## Installing from a flash drive:

```
mount /dev/sdd2 /mnt
sudo bash /mnt/scripts/nvidia39025gpu.sh
```

## Full automation notes

To install proprietary NVIDIA drivers from any installation point, this may
require:

- cronjobs to hook through reboots
- Progress checks
- Detect video output


Pseudo code: Change boot options.
```
if [[ $(cat /etc/*-release | grep ID_LIKE | grep rhel | wc -l) -gt 0 ]]; then
  echo "This is an rpm based system"

  # https://access.redhat.com/solutions/1155663
  # Edit /etc/default/grub and add the following to the GRUB_CMDLINE_LINUX line:
  # modprobe.blacklist=nouveau nomodeset 3
  # Rebuild the grub config and restart the system:
  # grub2-mkconfig -o /boot/grub2/grub.cfg
fi
  
if [[ $(cat /etc/*-release | grep ID_LIKE | grep rhel | wc -l) -gt 0 ]]; then
  echo "This is an rpm based system"
  
  # https://access.redhat.com/solutions/1155663
  # Edit /etc/default/grub and add the following to the GRUB_CMDLINE_LINUX line:
  # modprobe.blacklist=nouveau nomodeset 3
  # Rebuild the grub config and restart the system:
  # grub2-mkconfig -o /boot/grub2/grub.cfg
fi

if [[ $(cat /etc/*-release | grep \ 6 | grep -e CentOS -e rhel -e Scientific | wc -l) -gt 0 ]]; then
  echo "This is an rpm based system"
  echo "Major version 6."
  echo "This NVIDIA automated installation command will not work."
  echo "Run this command:"
  echo "   sudo sh /tmp/NVIDIA-Linux-x86_64-375.66.run"
  echo "Answer yes to all questions."
fi
```

## Which video output is in use

INCOMPLETE: Find the video output currently in use to decide between GPU or MB
workflow...

Use ```xrandr -q``` to find out information about video output.  The plus sign
```+``` signifies which display is in use.

https://askubuntu.com/questions/186288/

```lshw -numeric -C display```

```lspci -vnn | grep VGA -A 12```

```sudo dmidecode -t baseboard | grep -i 'Product'```

```inxi -M```

```glxinfo | grep OpenGL```

http://www.binarytides.com/linux-get-gpu-information/

```lspci -vnnn | perl -lne 'print if /^\d+\:.+(\[\S+\:\S+\])/' | grep VGA```

ubuntudroid from https://unix.stackexchange.com/questions/16407


# VGA example

```sudo lshw -c video```

```
  *-display               
       description: VGA compatible controller
       product: 4 Series Chipset Integrated Graphics Controller
       vendor: Intel Corporation
       physical id: 2
       bus info: pci@0000:00:02.0
       version: 03
       width: 64 bits
       clock: 33MHz
       capabilities: msi pm vga_controller bus_master cap_list rom
       configuration: driver=i915 latency=0
       resources: irq:28 memory:e0000000-e03fffff memory:d0000000-dfffffff ioport:f0f0(size=8)
```

https://unix.stackexchange.com/questions/47584

```
echo "Installing proprietary NVIDIA drivers..."
if [[ $(lspci | grep 1b38 | wc -l) -gt 0 ]] || [[ <INSERT RHEL DESCRIPTOR HERE> ]]; then
  echo "Tesla P40 found! OR RHEL found
  echo "Skipping DKMS..."
  echo "Installing NVIDIA drivers..."
else
  echo "Installing dkms..."
  echo "Installing NVIDIA drivers..."
fi
```

## Fedora 25 26 / wayland patch
https://ask.fedoraproject.org/en/question/103665/patch-for-proprietary-nvidia-37539-drivers-with-kernel-410/

https://pastebin.com/giS541m0

```
dnf install -y dkms
wget https://pastebin.com/raw/giS541m0
sh NVIDIA-Linux-x86_64-378.13.run -x
cp giS541m0 NVIDIA-Linux-x86_64-378.13/
cd NVIDIA-Linux-x86_64-378.13/
patch -p1 < patch.txt
./nvidia-installer
```

## Clean up installer

```
echo "Cleaning up..."
rm -f NVIDIA-Linux-x86_64-375.26.run 2>/dev/null
rm -f NVIDIA-Linux-x86_64-375.39.run 2>/dev/null
rm -f NVIDIA-Linux-x86_64-375.66.run 2>/dev/null
rm -f NVIDIA-Linux-x86_64-378.13.run 2>/dev/null
rm -rf NVIDIA-Linux-x86_64-375.39/ 2>/dev/null
rm -rf NVIDIA-Linux-x86_64-378.13/ 2>/dev/null
rm -f cuda_8.0.44_linux-run 2>/dev/null
rm -f cuda_8.0.61_375.26_linux-run 2>/dev/null
```


## Reboot

```
echo sleep 5 > /tmp/umsd.sh
echo umount /mnt >> /tmp/umsd.sh
echo reboot >> /tmp/umsd.sh
sh /tmp/umsd.sh
```

## Firmware

Based on https://www.techpowerup.com/244981/nvidia-has-a-displayport-problem-which-only-a-bios-update-can-fix#

An update has been released for DisplayPort 1.3 and 1.4 Displays.  Download the firmware update tool with this command:

```
wget -q http://us.download.nvidia.com/Windows/uefi/firmware/1.0/NVIDIA_DisplayPort_Firmware_Updater_1.0-x64.exe
```

Download NVFlash for GNU/Linux.

```
wget -q http://us2-dl.techpowerup.com/files/aQ27BSdlTc32tRHngOKP-A/1528742513/nvflash_5.414.0_linux.zip
```

Download NVFlash for Windows 7, 8, and 10.

```
wget -q http://us2-dl.techpowerup.com/files/jruKWF6V6N-WkYIbY72DBA/1528742523/nvflash_5.449.0.zip
```

These links were recent as of 2018-06-11.

Firmare should be acquired from your manufacterer or OEM.
