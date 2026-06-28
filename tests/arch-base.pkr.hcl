packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "memory" {
  type    = string
  default = "2048M"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "accelerator" {
  type    = string
  default = "kvm"
}

source "qemu" "arch-base" {
  iso_url          = "https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
  iso_checksum     = "file:https://geo.mirror.pkgbuild.com/iso/latest/sha256sums.txt"
  output_directory = "output-arch-base"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  disk_size        = "15000M"
  format           = "qcow2"
  accelerator      = var.accelerator
  headless         = true
  http_directory   = "."
  ssh_username     = "root"
  ssh_password     = "packer"
  ssh_timeout      = "20m"
  vm_name          = "arch-base.qcow2"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "5s"
  boot_command = [
    "<enter><wait45s>",
    "passwd<enter><wait5s>",
    "packer<enter><wait5s>",
    "packer<enter><wait5s>",
    "systemctl start sshd<enter><wait5s>"
  ]
  qemuargs = [
    ["-m", "${var.memory}"],
    ["-smp", "${var.cpus}"]
  ]
}

build {
  sources = ["source.qemu.arch-base"]

  provisioner "shell" {
    inline = [
      "mount -o remount,size=2G /run/archiso/cowspace || true",
      "pacman -Sy --noconfirm rsync make",
      "mkdir -p /tmp/arch-config"
    ]
  }

  provisioner "file" {
    source      = "../"
    destination = "/tmp/arch-config"
  }

  provisioner "shell" {
    inline = [
      "cd /tmp/arch-config",
      "CI=true make system EXTRA_VARS='-e \"DEVICE=/dev/vda SWAP_SIZE_MIB=512 HOSTNAME=archtest USERNAME=packer PASSWORD=packer ROOT_PASSWORD=packer\"'",
      "arch-chroot /mnt pacman -Sy --noconfirm openssh",
      "arch-chroot /mnt systemctl enable sshd",
      "arch-chroot /mnt systemctl set-default multi-user.target"
    ]
  }
}
