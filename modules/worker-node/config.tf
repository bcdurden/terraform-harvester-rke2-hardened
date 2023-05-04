resource "kubernetes_secret" "worker_config" {
  count = var.worker_count
  metadata {
    name = "${var.node_prefix}-worker-config-${count.index}"
  }

  type = "secret"

  data = {
    userdata = <<EOT
      #cloud-config
      write_files:
      - path: /etc/rancher/rke2/config.yaml
        owner: root
        content: |
          token: ${var.cluster_token}
          server: https://${var.master_hostname}:9345
          system-default-registry: ${var.rke2_registry}
          write-kubeconfig-mode: 0640
          profile: cis-1.6
          kube-apiserver-arg:
          - authorization-mode=RBAC,Node
          kubelet-arg:
          - protect-kernel-defaults=true
          - read-only-port=0
          - authorization-mode=Webhook
      - path: /etc/hosts
        owner: root
        content: |
          127.0.0.1 localhost
          127.0.0.1 "${var.node_prefix}-${count.index}"
          ${var.master_vip} ${var.master_hostname}
      - path: /etc/rancher/rke2/registries.yaml
        owner: root
        content: |
          mirrors:
            docker.io:
              endpoint:
                - "https://${var.rke2_registry}"
            ${var.rke2_registry}:
              endpoint:
                - "https://${var.rke2_registry}"
            ghcr.io:
              endpoint:
                - "https://${var.rke2_registry}"
          configs:
            "rgcrprod.azurecr.us":
              auth:
                username: ${var.carbide_username}
                password: ${var.carbide_password}
      runcmd:
      - - systemctl
        - enable
        - '--now'
        - qemu-guest-agent.service
      - INSTALL_RKE2_TYPE="agent" INSTALL_RKE2_VERSION=${var.rke2_version} sh /var/lib/rancher/install.sh
      - systemctl enable rke2-agent.service
      - cp -f /usr/local/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
      - systemctl restart systemd-sysctl
      - systemctl start rke2-agent.service
      ssh_authorized_keys: 
      - ${var.ssh_pubkey}
    EOT 
  }
}

