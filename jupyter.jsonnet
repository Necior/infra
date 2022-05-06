{
  local app = self,

  namespace: {
    apiVersion: 'v1',
    kind: 'Namespace',
    metadata: {
      name: 'jupyter',
    },
  },
  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        run: 'jupyter',
      },
      name: 'jupyter',
      namespace: app.namespace.metadata.name,
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          run: 'jupyter',
        },
      },
      template: {
        metadata: {
          labels: {
            run: 'jupyter',
          },
        },
        spec: {
          containers: [
            {
              image: 'jupyter/scipy-notebook:6b49f3337709',
              name: 'jupyter',
            },
          ],
          restartPolicy: 'Always',
          affinity: {
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [
                  {
                    matchExpressions: [
                      {
                        key: 'kubernetes.io/arch',
                        operator: 'In',
                        values: [
                          'amd64',
                        ],
                      },
                    ],
                  },
                ],
              },
            },
          },
        },
      },
    },
  },
}
