data "helm_repository" "vault" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "helm_release" "vault" {
  name          = "vault"
  chart         = "vault"
  repository    = "incubator"
  namespace     = "default"
  recreate_pods = true
  force_update  = true
  version       = "0.23.5"
  values = [
    <<EOF

replicaCount: 2 
resources: {}

image:
  repository: vault
  tag:
  pullPolicy: IfNotPresent

service:
  name: vault
  type: ClusterIP
  loadBalancerSourceRanges: []
  externalPort: 8200
  port: 8200
  clusterPort: 8201
  annotations: {}
  additionalSelector: {}

consulAgent:
  repository: consul
  tag: 1.7.1
  pullPolicy: IfNotPresent
  join: consul.default.svc
  gossipKeySecretName: consul-gossip-key
  HttpPort: 8500
  resources: {}

ingress:
  enabled: false
  labels: {}

nodeSelector: {}
tolerations: []
annotations: {}
labels: {}
podAnnotations: {}
podLabels: {}
priorityClassName: ""

minReadySeconds: 0
serviceAccount:
  create: true
  annotations: {}
  # name:

rbac:
  create: true

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: kubernetes.io/hostname
        labelSelector:
          matchLabels:
            app: '{{ template "vault.name" . }}'
            release: '{{ .Release.Name }}'

vault:
  # Only used to enable dev mode. When in dev mode, the rest of this config
  # section below is not used to configure Vault. See
  # https://www.vaultproject.io/intro/getting-started/dev-server.html for more
  # information.
  dev: true
  # Configure additional arguments to pass to vault server command
  extraArgs: []
  # Configure additional environment variables for the Vault containers
  extraEnv: []
  #   - name: VAULT_API_ADDR
  #     value: "https://vault.internal.domain.name:8200"
  extraContainers: []
  ## Additional containers to be added to the Vault pod
  # extraContainers:
  # - name: vault-sidecar
  #   image: vault-sidecar:latest
  #   volumeMounts:
  #   - name: some-mount
  #     mountPath: /some/path
  # Extra volumes to mount to the Vault pod. The comments show an example usage
  # for mounting a TLS secret. In this example, the volume name must match
  # the volumeMount name. The two other fields required are the name of the
  # Kubernetes secret (created outside of this chart), and the mountPath
  # at which it should be mounted in the Vault container.
  extraVolumes: []
  #   - name: vault-tls
  #     secret:
  #       secretName: vault-tls-secret
  extraVolumeMounts: []
  #   - name: vault-tls
  #     mountPath: /vault/tls
  #     readOnly: true
  extraInitContainers: []
  ## Init containers to be added
  # extraInitContainers:
  # - name: do-something
  #   image: busybox
  #   command: ['do', 'something']
  # Log level
  # https://www.vaultproject.io/docs/commands/server.html#log-level
  logLevel: "info"
  ## Additional volumes to the vault pod.
  # - name: extra-volume
  #   secret:
  #     secretName: some-secret
  liveness:
    aliveIfUninitialized: true
    aliveIfSealed: true
    initialDelaySeconds: 30
    periodSeconds: 10
  readiness:
    readyIfSealed: false
    readyIfStandby: true
    readyIfUninitialized: true
    initialDelaySeconds: 10
    periodSeconds: 10
  # Set the `VAULT_API_ADDR` environment variable to the Pod IP Address
  # This is the address (full URL) to advertise to other Vault servers in the cluster for client redirection.
  # See https://www.vaultproject.io/docs/configuration/#api_addr
  podApiAddress: true
  ## Use an existing config in a named ConfigMap
  # existingConfigName: vault-cm

  config:
    listener:
      tcp:
        address: '[::]:8200'
        cluster_address: '[::]:8201'
        tls_disable: true

    storage:
      consul:
        address: "127.0.0.1:8500"
        path: "vault"
  backendPolicy: []

EOF
    ,
  ]
}

