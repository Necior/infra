{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'redis-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'redis',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'redis',
          },
        },
        spec: {
          containers: [
            {
              name: 'redis',
              image: 'redis:6.2.5',
              resources: {
                requests: {
                  cpu: "0.001",
                  memory: "10Mi",
                },
                limits: {
                  cpu: "0.250",
                  memory: "100Mi",
                },
              },
              ports: [
                {
                  containerPort: 6379,
                },
              ],
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
      name: 'redis-service',
    },
    spec: {
      selector: {
        app: 'redis',
      },
      ports: [
        {
          protocol: 'TCP',
          port: 6379,
          targetPort: app.deployment.spec.template.spec.containers[0].ports[0].containerPort,
        },
      ],
    },
  },
}
