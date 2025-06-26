terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

provider "virtualbox" {}
resource "virtualbox_vm" "k3s_master" {
  name   = "k3s-master-node"
  image  = var.vm_template_name
  cpus   = var.master_cpu
  memory = "${var.master_memory}mib"

  network_adapter {
    type           = "bridged"
    host_interface = var.network_interface
    device = var.network_device
  }

  #network_adapter {
  #  type = "nat"
  #  device = var.network_device
  #}

  status = "running"
  lifecycle {
    ignore_changes = [
      memory,
      cpus,
    ]
  }
}

resource "virtualbox_vm" "k3s_workers" {
  count  = var.worker_count
  name   = "k3s-worker-node-0${count.index + 1}"
  image  = var.vm_template_name
  cpus   = var.worker_cpu
  memory = "${var.worker_memory}mib"

  network_adapter {
    type           = "bridged"
    host_interface = var.network_interface
    device = var.network_device
  }

  #network_adapter {
  #  type = "nat"
  #  device = var.network_device
  #}

  status = "running"
  lifecycle {
    ignore_changes = [
      memory,
      cpus,
    ]
  }
}

resource "local_file" "ansible_inventory" {
  content = <<-EOT
    [master]
    ${virtualbox_vm.k3s_master.name} ansible_host=${virtualbox_vm.k3s_master.network_adapter.0.ipv4_address}

    [workers]
    %{for i, vm in virtualbox_vm.k3s_workers~}
    ${vm.name} ansible_host=${vm.network_adapter.0.ipv4_address}
    %{endfor~}

    [all:vars]
    ansible_user=ubuntu
    ansible_password=windowshyun
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT

  filename = "../ansible/inventory.ini"
}