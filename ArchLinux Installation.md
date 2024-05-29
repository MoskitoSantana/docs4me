# Arch Linux Installation Guide

#### Check for efi installation
```bash
ls /sys/firmware/efi/efivars
```

#### Connect to wifi network
```bash
iwctl
device list
station device scan
station device get-networks
station device connect SSID
```

#### Check internet connection
```bash
ping -c 4 8.8.8.8
```

## Partitions Creation

#### List aviable devices

```sh
lsblk
```

```bash
cfdisk
```

#### Partition table example

| Device | Size | Type |
|--------|------|------|
|/dev/sdx1| 550M | EFI |
|/dev/sdx2| 2xRAM| SWAP |
|/dev/sdx3| Remaining (at least 20GB)| Linux filesystem|

### Btrfs filesystem creation

#### Formatting partitions created
##### EFI

```sh
mkfs.fat -F32 -L "Boot" /dev/sdx1
```
##### BTRFS
```sh
mkfs.btrfs -L "Main" /dev/sdx2
```
**Note :** In my case i won't create a swap partition , will be using a swapfile

#### Creating btrfs root
```sh
mkdir /mnt/btrfs-root
```


```sh
mount -o defaults,relatime,discard,ssd /dev/sdx2 /mnt/btrfs-root
```

#### Creating subvolumes
This is a [fairly standard](https://wiki.archlinux.org/index.php/Security#Partitions) way to partition the system.
```sh
mkdir -p /mnt/btrfs-root/__snapshot
mkdir -p /mnt/btrfs-root/__current
btrfs subvolume create /mnt/btrfs-root/__current/ROOT
btrfs subvolume create /mnt/btrfs-root/__current/@home
btrfs subvolume create /mnt/btrfs-root/__current/@opt
btrfs subvolume create /mnt/btrfs-root/__current/@var
```
The ____snapshot__ and ____current__ directories are created in the top-level subvolume of the BTRFS partition, and are used to distinguish between the subvolumes that are snapshots and those that are currently used as active subvolumes.

#### Listing subvolumes
```sh
btrfs subvolume list -p /mnt/btrfs-root/
```

#### Mounting subvolumes



```sh
mkdir -p /mnt/btrfs-current
```


```sh
mount -o defaults,relatime,discard,ssd,nodev,subvol=__current/ROOT /dev/sdx2 /mnt/btrfs-current
```

___

#### Efi partition
```sh
mkdir /mnt/btrfs-current/boot/efi -p
```

```sh
mount /dev/sdx1 /mnt/btrfs-current/boot/efi
```
___
```sh
mkdir -p /mnt/btrfs-current/home
mkdir -p /mnt/btrfs-current/opt
mkdir -p /mnt/btrfs-current/var/lib
```

```sh
mount -o defaults,relatime,discard,ssd,nodev,nosuid,subvol=__current/@home /dev/sdx2 /mnt/btrfs-current/home
mount -o defaults,relatime,discard,ssd,nodev,nosuid,subvol=__current/@opt /dev/sdx2 /mnt/btrfs-current/opt
mount -o defaults,relatime,discard,ssd,nodev,nosuid,noexec,subvol=__current/@var /dev/sdx2 /mnt/btrfs-current/var
```
## Installing the system
### Add custom repo to mirrorlist
```sh
vim /etc/pacman.d/mirrorlist
```

#### Comment all, and put (this only in Cuba) 
______
```vim
Server = http://repos.uo.edu.cu/archlinux/$repo/os/$arch
```
```sh
pacstrap /mnt/btrfs-current base linux-firmware linux-zen linux-zen-header neovim
git base-devel 
```

```sh
genfstab -U -p /mnt/btrfs-current >> /mnt/btrfs-current/etc/fstab
```

#### Fstab
Edit your fstab file to looks like this
______

```sh
vim /mnt/btrfs-current/etc/fstab
```
______

```conf
tmpfs /tmp tmpfs rw,nodev,nosuid 0 0
tmpfs /dev/shm tmpfs rw,nodev,noexec,nosuid

# /dev/sda2
/dev/sdx2		/         	btrfs     	rw,nodev,relatime,ssd,discard,space_cache=v2,subvol=/_current/ROOT	0 0

# /dev/sda2
/dev/sdx2	/home     	btrfs     	rw,nosuid,nodev,relatime,ssd,discard,space_cache=v2,subvol=/_current/@home	0 0

# /dev/sda2
/dev/sdx2	/opt      	btrfs     	rw,nosuid,nodev,relatime,ssd,discard,space_cache=v2,subvol=/_current/@opt	0 0

# /dev/sda2
/dev/sdx2	/var      	btrfs     	rw,noexec,nosuid,nodev,relatime,ssd,discard,space_cache=v2,subvol=/_current/@var	0 0

# /dev/sda2
/dev/sdx2	/run/btrfs-root         	btrfs     	rw,nodev,nosuid,noexec,relatime,ssd,discard,space_cache=v2	0 0

/run/btrfs-root/_current/ROOT/var/lib 	/var/lib 	none 	bind	0 0
```
______

## System Configuration

#### Load Chroot
______
```sh
arch-chroot /mnt
```
#### Configure Timezone
______
```sh
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc && date
```
Example: America/Havana
```sh
hwclock -w
```
______

```sh
locale-gen
echo LANG=lang_Country.UTF-8 > /etc/locale.conf
```
Example :
+ Spanish: es_ES
- English: en_US or en_UK
______

```sh
echo KEYMAp=us>/etc/vsconsole.conf
```

### Hostname configuration
```sh
echo your_hostname > /etc/hostname
```
___
### Configure Hosts
```sh
vim /etc/hosts
```

```
127.0.0.1 localhost your_hostname
::1 localhost
```

### Installing Network Manager 
```sh
pacman -S networkmanager dhcpcd wpa_supplicant netctl dialog
systemctl enable NetworkManager
```

### Set Root Password
```sh
passwd
```

### Ramdisk env
- [x] Remove fsck from the HOOKS line. BTRFS doesn’t have a fsck program, and leaving it in the HOOKS will only generate a warning.
- [x] Add btrfs to the HOOKS line.

```conf
HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems btrfs)
```

```sh
mkinitcpio -p
```

### Install the bootloader
```sh
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi
```

### Configure grub
```sh 
vim /etc/default/grub
```

#### Change this key
```conf
GRUB_CMDLINE_LINUX_DEFAULT="text"
```

```sh
grub-mkconfig -o /boot/grub/grub.cfg
```
### Reboot
```sh
exit
umount -R /mnt
reboot # Remove installation usb 
```
