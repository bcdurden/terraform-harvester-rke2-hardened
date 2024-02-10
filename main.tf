module "controlplane-nodes" {
  source = "./modules/controlplane-node"

  node_name_prefix              = var.main_cluster_prefix
  node_image_id                 = data.harvester_image.ubuntu2004-rke2.id
  vlan_id                       = data.harvester_network.target_network.id
  master_vip                    = var.master_vip
  ssh_key                       = tls_private_key.global_key.private_key_pem
  ssh_pubkey                    = tls_private_key.global_key.public_key_openssh
  rke2_registry                 = var.registry_url
  disk_size                     = var.node_disk_size
  controlplane_node_core_count  = var.control_plane_cpu_count
  controlplane_node_memory_size = var.control_plane_memory_size
  carbide_username              = var.carbide_username
  carbide_password              = var.carbide_password
  network_data                  = var.cp_network_data

  ha_mode = var.control_plane_ha_mode
}

module "worker" {
  source = "./modules/worker-node"
  depends_on = [
    module.controlplane-nodes.controlplane_node
  ]

  worker_count            = var.worker_count
  node_prefix             = var.worker_prefix
  node_image_id           = data.harvester_image.ubuntu2004-rke2.id
  vlan_id                 = data.harvester_network.target_network.id
  master_vip              = var.master_vip
  ssh_key                 = tls_private_key.global_key.private_key_pem
  ssh_pubkey              = tls_private_key.global_key.public_key_openssh
  rke2_registry           = var.registry_url
  disk_size               = var.node_disk_size
  worker_node_core_count  = var.worker_cpu_count
  worker_node_memory_size = var.worker_memory_size
  carbide_username        = var.carbide_username
  carbide_password        = var.carbide_password
}