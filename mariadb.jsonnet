local private = import 'private.libsonnet';

{
  local app = self,
  rs: {
    apiVersion: 'apps/v1',
    kind: 'ReplicaSet',
    metadata: {
      name: 'mariadb',
      labels: {
        app: 'mariadb',
      },
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          app: 'mariadb',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'mariadb',
          },
        },
        spec: {
          containers: [
            {
              name: 'mariadb',
              image: 'mariadb:focal',
              resources: {
                requests: {
                  cpu: '1m',
                  memory: '100Mi',
                },
                limits: {
                  cpu: '100m',
                  memory: '500Mi',
                },
              },
              env: [
                {
                  name: 'MARIADB_ROOT_PASSWORD',
                  value: private.mariadb_root_password,
                },
              ],
              livenessProbe: {
                tcpSocket: {
                  port: 3306,
                },
              },
              ports: [
                {
                  containerPort: 3306,
                },
              ],
              volumeMounts: [
                {
                  name: 'mariadb',
                  mountPath: '/var/lib/mysql',
                },
              ],
            },
          ],
          volumes: [
            {
              name: 'mariadb',
              persistentVolumeClaim: {
                claimName: app.pvc.metadata.name,
              },
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
      name: 'mariadb',
    },
    spec: {
      ports: [
        {
          port: 3306,
          protocol: 'TCP',
        },
      ],
      selector: {
        app: 'mariadb',
      },
    },
  },

  pvc: {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'mariadb',
    },
    spec: {
      accessModes: ['ReadWriteOnce'],
      storageClassName: 'local-path',
      resources: {
        requests: {
          storage: '1Gi',
        },
      },
    },
  },
}
