variable "ansible_connection" {
  type    = string
  default = "docker"
}

variable "ansible_host" {
  type    = string
  default = "default"
}

source "docker" "alpine" {
  commit      = true
  image       = "alpine:latest"
  run_command = ["-d", "-i", "-t", "--name", var.ansible_host, "{{.Image}}", "/bin/sh"]
}

source "docker" "centos" {
  commit      = true
  image       = "centos:latest"
  run_command = ["-d", "-i", "-t", "--name", var.ansible_host, "{{.Image}}", "/bin/sh"]
}

source "docker" "ubuntu" {
  commit      = true
  image       = "ubuntu:latest"
  run_command = ["-d", "-i", "-t", "--name", var.ansible_host, "{{.Image}}", "/bin/sh"]
}

build {
  sources = [
    "source.docker.alpine"
  ]

  provisioner "ansible" {
    extra_arguments      = [
      "--extra-vars",
      "ansible_host=${var.ansible_host} ansible_connection=${var.ansible_connection}"
    ]
    galaxy_file          = "ansible/roles/requirements.yml"
    galaxy_force_install = true
    playbook_file        = "ansible/site.yml"
    user                 = "root"
  }
  post-processor "docker-tag" {
    repository = "packer-ansible-test"
    tags       = [
      "latest"
    ]
  }
}
