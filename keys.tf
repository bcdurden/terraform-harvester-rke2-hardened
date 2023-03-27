resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}