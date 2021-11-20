{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'mongodb-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'mongodb',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'mongodb',
          },
        },
        spec: {
          containers: [
            {
              name: 'mongodb',
              image: 'mongo:latest',
              resources: {
                requests: {
                  cpu: '1m',
                  memory: '10Mi',
                },
                limits: {
                  cpu: '250m',
                  memory: '100Mi',
                },
              },
              volumeMounts: [
                {
                  name: app.deployment.spec.template.spec.volumes[0].name,
                  mountPath: '/data/db',
                },
              ],
              ports: [
                {
                  containerPort: 27017,
                },
              ],
            },
          ],
          volumes: [
            {
              name: app.pvc.metadata.name,
              persistentVolumeClaim: { claimName: app.pvc.metadata.name },
            },
          ],

          tolerations: [
            {
              key: 'necior/arch',
              value: 'aarch64',
              effect: 'NoSchedule',
            },
          ],

        },
      },
    },
  },

  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'mongodb-service',
    },
    spec: {
      selector: {
        app: 'mongodb',
      },
      ports: [
        {
          protocol: 'TCP',
          port: 27017,
          targetPort: app.deployment.spec.template.spec.containers[0].ports[0].containerPort,
        },
      ],
    },
  },

  pvc: {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'database',
    },
    spec: {
      accessModes: [
        'ReadWriteOnce',
      ],
      storageClassName: 'local-path',
      resources: {
        requests: {
          storage: '2Gi',
        },
      },
    },
  },
}
