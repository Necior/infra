#!/usr/bin/env sh

# stolen from
# https://github.com/kubernetes-sigs/kind/issues/1719#issuecomment-658377560

cat <<EOF | kind create cluster --config=-                                 
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
 [plugins."io.containerd.grpc.v1.cri".containerd]
 snapshotter = "native"
EOF

