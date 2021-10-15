
variable "ubuntu_image" {
  type    = string
  default = "ubuntu:focal"
}

variable "centos_image" {
  type    = string
  default = "centos:8"
}

variable "user" {
  type    = string
  default = "moose"
}

variable "uid" {
  type    = number
  default = 700
}

packer {
  required_plugins {
    docker = {
      version = "= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "centos" {
  image  = var.centos_image
  commit = true
}

source "docker" "ubuntu" {
  image  = var.ubuntu_image
  commit = true
}

build {
  name = "linux-build"
  sources = [
    "source.docker.centos",
    "source.docker.ubuntu"
  ]
  provisioner "shell" {
    inline = [
      "echo \"Running platform agnostic provisioning\"",
      "mkdir /usr/local/scr",
      "touch /usr/local/scr/stats.log",
      "cat /etc/os-release"
    ]
  }
  provisioner "file" {
    source      = "playbook.yml"
    destination = "/usr/local/playbook.yml"
  }
  provisioner "file" {
    source      = "create_user"
    destination = "/usr/local/scr/create_user"
  }
  provisioner "shell" {
    inline = [
      "/usr/local/scr/create_user ${var.user} ${var.uid}"
    ]
  }
  provisioner "shell" {
    only = ["docker.centos"]
    inline = [
      "yum update -y",
      "yum install -y sudo python3 epel-release",
      "yum install -y ansible"
    ]
  }
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    only = ["docker.ubuntu"]
    inline = [
      "apt-get update -y",
      "apt-get install -y sudo python3-dev software-properties-common",
      "add-apt-repository -y --update ppa:ansible/ansible",
      "apt-get install -y ansible"
    ]
  }
  post-processor "docker-tag" {
    repository = "linux-build"
    tags       = ["ub2004"]
    only       = ["docker.ubuntu"]
  }
  post-processor "docker-tag" {
    repository = "linux-build"
    tags       = ["co8"]
    only       = ["docker.centos"]
  }
}