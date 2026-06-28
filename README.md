![arch](https://img.shields.io/badge/Arch%20Linux-blue?style=plastic&logo=archlinux)
![ansible](https://img.shields.io/badge/Ansible-black?style=plastic&logo=ansible)
[![GitHub main branch check runs](https://img.shields.io/github/check-runs/vncsmyrnk/arch-config/main?style=plastic&logo=github&label=CI)](https://github.com/vncsmyrnk/arch-config/actions/workflows/ci.yaml)

# Arch

Useful information about arch config and utilities.

This repo also provides ansible playbooks containing an opinionated arch install and user configuration. Use them carefully.

## Install system and user config

```sh
make help
```

## Testing

This repository uses Packer and QEMU to provide verifiable, OS-agnostic testing of the playbooks locally.

**Prerequisites:**
- [QEMU/KVM](https://www.qemu.org/download/)
- [Packer](https://developer.hashicorp.com/packer/downloads)

Run the test gates:

```sh
# Test the system install playbook (system.yml) inside a QEMU VM booting from the Arch ISO
make test-system

# Test the user config playbook (user.yml) using the base image generated above
make test-user

# Run both tests
make test-all
```


## Useful links

- [Wiki](https://wiki.archlinux.org/title/Main_page)
- [ISOs](https://archlinux.org/download/)

## Encrypting partitions

[dm-crypt](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)<br>
[GRUB Setup](https://bbs.archlinux.org/viewtopic.php?id=301301)<br>
[Reencrypt a device](https://unix.stackexchange.com/questions/444931/is-there-a-way-to-encrypt-disk-without-formatting-it)<br>
[GRUB regenerate the config file](https://wiki.archlinux.org/title/GRUB#Generate_the_main_configuration_file)<br>
[Removing system encryption](https://wiki.archlinux.org/title/Removing_system_encryption)

## Installation caveats

### Networking

Reference: https://wiki.archlinux.org/title/Network_configuration

```bash
cat <<EOF > /etc/systemd/network/20-wired.network
[Match]
Name=enp2s0

[Network]
DHCP=yes
EOF
```

```bash
cat "nameserver 8.8.8.8" > /etc/resolv.conf
sudo pacman -S networkmanager
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
```

```bash
ping 8.8.8.8 # for testing
```

### GPU Drivers

#### AMD

```bash
sudo pacman -S mesa xf86-video-amdgpu
```

#### NVIDIA

```bash
sudo pacman -S mesa nvidia-open
```

Make sure to also install `envycontrol` for switching between integrated and dedicated cards and  `nvtop` to monitor GPU usage.

### Using system clipboard in vim

Vim is useful during the installation for running the commands one by one. Using the system clipboard in this scenario is very useful.

- Install `gvim`
- Set the clipboard inside vim: `set clipboard=unnamedplus`

### Increase archiso disk space

When needing space for installing packages on the archiso:

```sh
mount -o remount,size=1G /run/archiso/cow
```

## Best practices

### LTS kernel

Install `linux-lts` and `linux-lts-headers` alongside `linux` and `linux-headers`. The LTS kernel can be useful if some regression problem on kernel updates.

When using GRUB, regenerate the configuration file. This ensures the LTS kernel appears on "Advanced options" section.
