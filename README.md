# On-Premise Kubernetes(k3s) Cluster Automation with Terraform & Ansible

이 프로젝트는 개인 서버의 VirtualBox 환경에 수동으로 가상머신을 생성하고 설정하는 대신, Terraform과 Ansible을 사용하여 Kubernetes(k3s) 클러스터의 프로비저닝부터 구성까지 모든 과정을 코드로 자동화하는 것을 목표로 합니다.

이 저장소는 IaC와 Configuration Management의 핵심 원칙을 실제 On-Premise 환경에 적용한 경험을 기록하고 공유하기 위해 만들어졌습니다.

## 🚀 프로젝트 아키텍처

이 자동화 파이프라인은 다음과 같은 구조로 동작합니다.

1.  **사용자**는 Terraform과 Ansible을 실행합니다.
2.  **Terraform**은 VirtualBox에 미리 준비된 VM 템플릿을 복제하여 마스터 노드 1대와 워커 노드 N대의 VM을 생성합니다.
    - VM 생성 직후, `remote-exec` 프로비저너를 통해 각 VM에 고유한 호스트 이름을 설정합니다.
    - 생성된 VM들의 IP 주소와 접속 정보를 담은 `inventory.ini` 파일을 Ansible을 위해 동적으로 생성합니다.
3.  **Ansible**은 Terraform이 생성한 인벤토리 파일을 읽어 각 VM에 SSH로 접속합니다.
    - 마스터 노드에 k3s 서버를 설치하고 클러스터 Join Token을 가져옵니다.
    - 워커 노드에 k3s 에이전트를 설치하고, 마스터의 Token을 사용하여 클러스터에 자동으로 참여시킵니다.
4.  모든 과정이 완료되면, 사용자는 완전히 구성된 **Kubernetes 클러스터**를 즉시 사용할 수 있습니다.

## ✨ 주요 특징

- **완전 자동화**: 명령어 몇 개로 인프라 생성부터 쿠버네티스 클러스터 구성까지 End-to-End 자동화.
- **Infrastructure as Code**: Terraform을 사용하여 모든 가상머신 인프라를 코드로 명확하게 정의하고 관리.
- **Configuration Management**: Ansible을 사용하여 모든 서버의 소프트웨어 설치 및 구성을 코드로 관리.
- **동적 인벤토리**: Terraform이 생성한 인프라 정보를 Ansible이 즉시 사용할 수 있도록 동적으로 인벤토리 파일 생성.
- **재현성 및 일관성**: 언제 어디서든 동일한 구성의 클러스터를 오차 없이, 10분 내에 구축 가능.

## 📁 프로젝트 구조

이 프로젝트는 역할에 따라 두 개의 메인 디렉토리로 분리되어 있습니다.

```
.
├── terraform/     # Terraform 코드 (인프라 프로비저닝)
│   ├── 1_main.tf
│   ├── 2_variables.tf
│   ├── 3_outputs.tf
│   └── terraform.tfvars
│   └── ubuntu-2204.box
│
└── ansible/                    # Ansible 코드 (서버 구성 관리)
    ├── inventory.ini         # (Terraform이 자동으로 생성)
    └── install_k3s.yml
```

## 🛠️ 시작하기 전에 (Prerequisites)

이 프로젝트를 실행하기 위해서는 Host PC에 아래의 도구들이 설치되어 있어야 합니다.

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [ubuntu-2204.box](https://file.thisisserver.com/share/QwA92XAY) (유효 다운로드 기간 : 2025년 12월 23일 까지)
- `sshpass` (Ansible의 비밀번호 기반 접속을 위해 필요)

## ⚙️ 사용 방법 (Step-by-Step Guide)

#### 1단계: 베이스 VM 템플릿 준비

- `ubuntu-2204.box`를 다운로드 합니다.

#### 2단계: 저장소 복제 및 변수 설정

```bash
git clone https://github.com/WindowsHyun/terraform-vbox-k3s
cd /home/ubuntu/terraform-vbox-k3s
```

#### 3단계: 인프라 프로비저닝 (Terraform)

```bash
# terraform-vbox-k3s 디렉토리에서 실행
terraform init
terraform apply -auto-approve
```

- 이 과정이 완료되면 `ansible/inventory.ini` 파일이 자동으로 생성/업데이트됩니다.

#### 4단계: 클러스터 구성 (Ansible)

```bash
# ansible 디렉토리로 이동
cd ../ansible

# Ansible 플레이북 실행
ansible-playbook -i inventory.ini install_k3s.yml
```

#### 5단계: 클러스터 상태 확인

```bash
# Terraform Output으로 나온 마스터 노드 IP로 접속
ssh ubuntu@[마스터_노드_IP]

# 접속 후, 노드 상태 확인
sudo kubectl get nodes -o wide
```

## 💡 학습 및 트러블슈팅 경험

이 프로젝트를 진행하며 `No route to host` 네트워크 문제, Host/Guest 방화벽 설정, Ansible의 멱등성 함정, Hostname 중복으로 인한 클러스터 Join 실패 등 다양한 실제적인 문제들을 해결했습니다.
