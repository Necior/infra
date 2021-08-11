#!/usr/bin/env sh

# stolen from
# https://github.com/kubernetes-sigs/kind/issues/1719#issuecomment-658377560

cat <<EOF | kind create cluster --config=-                                 
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
- role: worker
containerdConfigPatches:
- |-
 [plugins."io.containerd.grpc.v1.cri".containerd]
 snapshotter = "native"
EOF

