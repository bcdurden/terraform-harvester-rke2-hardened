module "rke2-hardened" {
  source  = "../"
  
  main_cluster_prefix = "rke2-test-cp"
  worker_prefix = "rke2-test-worker"
  master_vip = "10.10.5.10"
  worker_count = "3"
  control_plane_cpu_count = "4"
  control_plane_memory_size = "8Gi"
  worker_cpu_count = "4"
  worker_memory_size = "8Gi"
  harvester_rke2_image_name = "image-xrrhd"
  target_network_name = "services"
  registry_url = "harbor.sienarfleet.systems"
  carbide_username = ""
  carbide_password = ""
  cp_network_data = [
    <<EOT
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: no
      addresses: [10.10.5.20/24]
      gateway4: 10.10.5.1
      nameservers:
        addresses: [10.10.0.1]
    EOT
    ]
}