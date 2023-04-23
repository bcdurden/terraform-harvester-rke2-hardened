resource "kubernetes_secret" "cp_main_config" {
  metadata {
    name = "${var.node_name_prefix}-cp-config"
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
          system-default-registry: ${var.rke2_registry}
          tls-san:
            - ${var.node_name_prefix}-0
            - ${var.master_hostname}
            - ${var.master_vip}
          profile: cis-1.6
          selinux: true
          secrets-encryption: true
          write-kubeconfig-mode: 0640
          use-service-account-credentials: true
          kube-controller-manager-arg:
          - bind-address=127.0.0.1
          - use-service-account-credentials=true
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          kube-scheduler-arg:
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          kube-apiserver-arg:
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          - authorization-mode=RBAC,Node
          - anonymous-auth=false
          - audit-policy-file=/etc/rancher/rke2/audit-policy.yaml
          - audit-log-mode=blocking-strict
          - audit-log-maxage=30
          kubelet-arg:
          - protect-kernel-defaults=true
          - read-only-port=0
          - authorization-mode=Webhook
          - streaming-connection-idle-timeout=5m
      - path: /etc/hosts
        owner: root
        content: |
          127.0.0.1 localhost
          127.0.0.1 ${var.node_name_prefix}-0
          127.0.0.1 ${var.master_hostname}
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
      - INSTALL_RKE2_ARTIFACT_PATH=/var/lib/rancher/rke2-artifacts sh /var/lib/rancher/install.sh
      - cat /var/lib/rancher/kube-vip-k3s |  vipAddress=${var.master_vip} vipInterface=${var.master_vip_interface} sh | sed -e 's|ghcr.io/kube-vip|${var.rke2_registry}/kube-vip|g' | sudo tee /var/lib/rancher/rke2/server/manifests/vip.yaml
      - systemctl enable rke2-server.service
      - cp -f /usr/local/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
      - useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
      - systemctl restart systemd-sysctl
      - systemctl start rke2-server.service
      ssh_authorized_keys: 
      - ${var.ssh_pubkey}
    EOT 
  }
}

resource "kubernetes_secret" "cp_ha_config" {
  count = var.ha_mode ? 2 : 0
  metadata {
    name = "${var.node_name_prefix}-cp-ha-config-${count.index + 1}"
  }

  type = "secret"

  data = {
    userdata = <<EOT
      #cloud-config
      package_update: true
      write_files:
      - path: /etc/rancher/rke2/config.yaml
        owner: root
        content: |
          token: ${var.cluster_token}
          server: https://${var.master_hostname}:9345
          system-default-registry: ${var.rke2_registry}
          tls-san:
            - ${var.node_name_prefix}-${count.index + 1}
            - ${var.master_hostname}
            - ${var.master_vip}
          profile: cis-1.6
          selinux: true
          secrets-encryption: true
          write-kubeconfig-mode: 0640
          use-service-account-credentials: true
          kube-controller-manager-arg:
          - bind-address=127.0.0.1
          - use-service-account-credentials=true
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          kube-scheduler-arg:
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          kube-apiserver-arg:
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          - authorization-mode=RBAC,Node
          - anonymous-auth=false
          - audit-policy-file=/etc/rancher/rke2/audit-policy.yaml
          - audit-log-mode=blocking-strict
          - audit-log-maxage=30
          kubelet-arg:
          - protect-kernel-defaults=true
          - read-only-port=0
          - authorization-mode=Webhook
          - streaming-connection-idle-timeout=5m
      - path: /etc/hosts
        owner: root
        content: |
          127.0.0.1 localhost
          127.0.0.1 ${var.node_name_prefix}-${count.index + 1}
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
      - INSTALL_RKE2_ARTIFACT_PATH=/var/lib/rancher/rke2-artifacts sh /var/lib/rancher/install.sh
      - systemctl enable rke2-server.service
      - cp -f /usr/local/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
      - useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
      - systemctl restart systemd-sysctl
      - systemctl start rke2-server.service
      ssh_authorized_keys: 
      - ${var.ssh_pubkey}
    EOT 
  }
}