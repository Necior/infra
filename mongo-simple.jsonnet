{
  sts: {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: 'mongo',
    },
    spec: {
      serviceName: 'mongo',
      replicas: 3,
      selector: {
        matchLabels: {
          app: 'mongo',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'mongo',
          },
        },
        spec: {
          containers: [
            {
              name: 'mongodb',
              image: 'mongo:5.0.4',
              command: ['mongod', '--replSet', 'rs0'],
              ports: [
                {
                  containerPort: 27017,
                  name: 'peer',
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

  svc: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'mongo',
    },
    spec: {
      ports: [
        {
          port: 27017,
          name: 'peer',
        },
      ],
      clusterIP: 'None',
      selector: {
        app: 'mongo',
      },
    },
  },
}
