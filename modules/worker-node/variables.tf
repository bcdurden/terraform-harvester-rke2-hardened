variable "node_prefix" {
    type = string
}
variable "namespace" {
    type = string
    default = "default"
}
variable "disk_size" {
    type = string
    default = "40Gi"
}
variable "node_image_id" {
    type = string
}
variable "ssh_keys" {
    type = list
    default = []
}
variable "vlan_id" {
    type = string
}
variable "master_hostname" {
    type = string
    default = "rke2master"
}
variable "master_vip" {
    type = string
}
variable "network_data" {
    type = string
    default = ""
}
variable "rke2_version" {
    type = string
    default = "v1.24.3+rke2r1"
}
variable "cluster_token" {
    type = string
    default = "my-shared-token"
}
variable "ssh_pubkey" {
    type = string
    default = ""
}
variable "ssh_key" {
    type = string
}
variable "worker_count" {
    type = number
    default = 3
}
variable "worker_node_core_count" {
    type = string
}
variable "worker_node_memory_size" {
    type = string
}
variable "rke2_registry" {
    type = string
}
variable "carbide_password" {
    type = string
}
variable "carbide_username" {
    type = string
}