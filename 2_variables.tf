variable "vm_template_name" {
  description = "복제할 VirtualBox VM 템플릿 이름"
  type        = string
}

variable "network_interface" {
  description = "VM을 연결할 호스트의 네트워크 인터페이스"
  type        = string
  default = "enp3s0"
}

variable "master_cpu" {
  description = "마스터 노드의 CPU 개수"
  type        = number
  default     = 2
}

variable "master_memory" {
  description = "마스터 노드의 메모리(MB)"
  type        = number
  default     = 2048
}

variable "worker_count" {
  description = "생성할 워커 노드의 수"
  type        = number
  default     = 2
}

variable "worker_cpu" {
  description = "워커 노드의 CPU 개수"
  type        = number
  default     = 1
}

variable "worker_memory" {
  description = "워커 노드의 메모리(MB)"
  type        = number
  default     = 1024
}

variable "network_device" {
  description = "VirtualBox Network Device"
  type        = string
  default     = "IntelPro1000MTDesktop"
}