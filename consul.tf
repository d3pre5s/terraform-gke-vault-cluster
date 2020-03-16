resource "helm_release" "consul" {
  name          = "consul"
  chart         = "stable/consul"
  namespace     = "default"
  recreate_pods = true
  force_update  = true
  values = [
    <<EOF

## Consul service ports
HttpPort: 8500
RpcPort: 8400
SerflanPort: 8301
SerflanUdpPort: 8301
SerfwanPort: 8302
SerfwanUdpPort: 8302
ServerPort: 8300
ConsulDnsPort: 8600

## Specify the domain with which consul should run with
## This will be passed as a -domain parameter
Domain: consul

## Used as selector
Component: "consul"
Replicas: 2
Image: "consul"
ImageTag: "1.7.1"
ImagePullPolicy: "Always"
Resources: {}
 # requests:
 #   cpu: "100m"
 #   memory: "256Mi"
 # limits:
 #   cpu: "500m"
 #   memory: "512Mi"
## Persistent volume size

priorityClassName: ""

Storage: "1Gi"

## Needed for 0.8.0 and later IF all consul containers are spun up
## on the same machine. Without this they all generate the same
## host id.
DisableHostNodeId: false

## Explicitly set LAN hosts to join.
# Added as -retry-join argument
# If you set joinPeers then we will not auto-build the list of peers for you
# These hostnames will be verified to be resolvable and ping-able before the consul service will start
joinPeers: []

## Set list of WAN hosts to join
# Added as -retry-join-wan argument
# These hostnames will be verified to be resolvable before the consul service will start
joinWan: []

## Encrypt Gossip Traffic
Gossip:
  Encrypt: true
  Create: true

## Setting maxUnavailable will create a pod disruption budget that will prevent
## voluntarty cluster administration from taking down too many consul pods. If
## you set maxUnavailable, you should set it to ceil((n/2) - 1), where
## n = Replicas. For example, if you have 5 or 6 Replicas, you'll want to set
## maxUnavailable = 2. If you are using the default of 3 Replicas, you'll want
## to set maxUnavailable to 1.
maxUnavailable: 1

## Affinity settings
affinity: |
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      podAffinityTerm:
        topologyKey: kubernetes.io/hostname
        labelSelector:
          matchExpressions:
          - key: component
            operator: In
            values:
            - "{{ .Release.Name }}-{{ .Values.Component }}"
## Enable Consul Web UI
##
ui:
  enabled: true
## Create dedicated UI service
##
uiService:
  enabled: true
  type: "NodePort"
  annotations: {}

ConsulConfig: []
#  - type: secret
#    name: consul-defaults
#  - type: configMap
#    name: consul-defaults

## Create an Ingress for the Web UI
uiIngress:
  enabled: false
  annotations: {}
  labels: {}
  hosts: []
  path: /
  tls: []

nodeSelector: {}
tolerations: []
additionalLabels: {}
podAnnotations: {}

# Lifecycle for StatefulSet
# lifecycle:
#   preStop:
#     exec:
#       command:
#       - sh
#       - -c
#       - "sleep 60"
forceIpv6: false

EOF
    ,
  ]
}

