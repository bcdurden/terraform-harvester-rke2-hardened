resource "ssh_resource" "retrieve_config" {
  host = module.controlplane-nodes.controlplane_node.network_interface[index(module.controlplane-nodes.controlplane_node.network_interface.*.name, "default")].ip_address
  depends_on = [
    module.controlplane-nodes.controlplane_node
  ]
  commands = [
    "sudo sed \"s/127.0.0.1/${var.master_vip}/g\" /etc/rancher/rke2/rke2.yaml"
  ]
  user        = "ubuntu"
  private_key = tls_private_key.global_key.private_key_pem
}
resource "local_file" "kube_config_server_yaml" {
  filename = var.kubeconfig_filename
  content  = ssh_resource.retrieve_config.result
}