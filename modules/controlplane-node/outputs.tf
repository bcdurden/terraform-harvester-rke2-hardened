# output "node_vm_ip" {
#     value = harvester_virtualmachine.node.network_interface[index(harvester_virtualmachine.node.network_interface.*.name, "default")].ip_address
# }
output "controlplane_node" {
  value = harvester_virtualmachine.node-main
}