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

source "qemu" "arch-user" {
  iso_url          = "output-arch-base/arch-base.qcow2"
  iso_checksum     = "none"
  disk_image       = true
  output_directory = "output-arch-user"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  disk_size        = "15000M"
  format           = "qcow2"
  accelerator      = "kvm"
  headless         = true
  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "20m"
  vm_name          = "arch-user.qcow2"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  qemuargs = [
    ["-m", "${var.memory}"],
    ["-smp", "${var.cpus}"]
  ]
}

build {
  sources = ["source.qemu.arch-user"]

  provisioner "shell" {
    inline = ["mkdir -p /tmp/arch-config"]
  }

  provisioner "file" {
    source      = "../"
    destination = "/tmp/arch-config"
  }

  provisioner "shell" {
    inline = [
      "sudo pacman -Sy --noconfirm make",
      "cd /tmp/arch-config",
      "CI=true make config EXTRA_VARS='-e \"ansible_become_pass=packer\"'"
    ]
  }
}
