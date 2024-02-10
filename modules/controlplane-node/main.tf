resource "harvester_virtualmachine" "node-main" {
  name                 = "${var.node_name_prefix}-0"
  namespace            = var.namespace
  restart_after_update = true

  depends_on = [
    kubernetes_secret.cp_main_config
  ]

  description = "Mgmt Cluster Control Plane node"
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

  cpu    = var.controlplane_node_core_count
  memory = var.controlplane_node_memory_size

  run_strategy = "RerunOnFailure"
  hostname     = "${var.node_name_prefix}-0"
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
    type                  = "noCloud"
    user_data_secret_name = "${var.node_name_prefix}-cp-config"
    network_data          = var.network_data[0]
  }
}
resource "harvester_virtualmachine" "node-ha" {
  count = var.ha_mode ? 2 : 0
  name  = "${var.node_name_prefix}-${count.index + 1}"
  depends_on = [
    harvester_virtualmachine.node-main
  ]
  namespace            = var.namespace
  restart_after_update = true

  description = "Mgmt Cluster Control Plane node"
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

  cpu    = var.controlplane_node_core_count
  memory = var.controlplane_node_memory_size

  run_strategy = "RerunOnFailure"
  hostname     = "${var.node_name_prefix}-${count.index + 1}"
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
    type                  = "noCloud"
    user_data_secret_name = "${var.node_name_prefix}-cp-ha-config-${count.index + 1}"
    network_data          = var.network_data[count.index + 1]
  }
}