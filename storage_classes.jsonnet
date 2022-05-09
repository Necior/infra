{
  default: {
    apiVersion: 'storage.k8s.io/v1',
    kind: 'StorageClass',
    metadata: {
      name: 'local-path',
    },
    provisioner: 'rancher.io/local-path',
    reclaimPolicy: 'Delete',
  },

  noAutoremove: {
    apiVersion: 'storage.k8s.io/v1',
    kind: 'StorageClass',
    metadata: {
      name: 'no-autoremove',
    },
    provisioner: 'rancher.io/local-path',
    reclaimPolicy: 'Retain',
    volumeBindingMode: 'WaitForFirstConsumer',
  },
}
