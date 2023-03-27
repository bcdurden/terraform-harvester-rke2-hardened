output "ssh_key" {
    value = tls_private_key.global_key.private_key_pem
    sensitive = true
}
output "ssh_pubkey" {
    value = tls_private_key.global_key.public_key_openssh
}
output "kube" {
    value = ssh_resource.retrieve_config.result
    sensitive = true
}