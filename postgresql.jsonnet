local private = import 'private.libsonnet';

{
  local app = self,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'postgresql-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'postgresql',
        },
      },
      replicas: 1,
      template: {
        metadata: {
          labels: {
            app: 'postgresql',
          },
        },
        spec: {
          containers: [
            {
              name: 'postgresql',
              image: 'postgres:14.1',
              imagePullPolicy: 'IfNotPresent',
              env: [
                { name: 'POSTGRES_PASSWORD', value: private.postgresql_postgres_password },
              ],
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
                  mountPath: '/var/lib/postgresql/data',
                },
              ],
              ports: [
                {
                  containerPort: 5432,
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
      name: 'postgresql-service',
    },
    spec: {
      selector: {
        app: 'postgresql',
      },
      ports: [
        {
          protocol: 'TCP',
          port: 5432,
          targetPort: app.deployment.spec.template.spec.containers[0].ports[0].containerPort,
        },
      ],
    },
  },

  pvc: {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'postgresql-database',
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
