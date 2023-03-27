resource "harvester_virtualmachine" "node" {
  count = var.worker_count

  depends_on = [
    kubernetes_secret.worker_config
  ]

  name                 = "${var.node_prefix}-${count.index}"
  namespace            = var.namespace
  restart_after_update = true

  description = "Mgmt Cluster Worker node"
  tags = {
    ssh-user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface[index(self.network_interface.*.name, "default")].ip_address
      user        = "ubuntu"
      private_key = var.ssh_key
    }
  }

  cpu    = var.worker_node_core_count
  memory = var.worker_node_memory_size

  run_strategy = "RerunOnFailure"
  hostname     = "${var.node_prefix}-${count.index}"
  machine_type = "q35"

  ssh_keys = var.ssh_keys
  network_interface {
    name           = "default"
    network_name   = var.vlan_id
    wait_for_lease = true
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = var.disk_size
    bus        = "virtio"
    boot_order = 1

    image       = var.node_image_id
    auto_delete = true
  }
  
  cloudinit {
    type      = "noCloud"
    user_data_secret_name = "worker-config-${count.index}"
    network_data = var.network_data
  }
}