output "k3s_master_ip" {
  value       = virtualbox_vm.k3s_master.network_adapter[0].ipv4_address
  description = "Host-only 네트워크상의 master IP"
}

output "k3s_workers_ips" {
  value       = [for vm in virtualbox_vm.k3s_workers : vm.network_adapter[0].ipv4_address]
  description = "Host-only 네트워크상의 workers IP 목록"
}