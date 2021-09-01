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
                  cpu: '0.001',
                  memory: '10Mi',
                },
                limits: {
                  cpu: '0.250',
                  memory: '100Mi',
                },
              },
              ports: [
                {
                  containerPort: 27017,
                },
              ],
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
}
