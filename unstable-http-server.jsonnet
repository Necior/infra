local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'unstable-http-server-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'unstable-http-server',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'unstable-http-server',
          },
        },
        spec: {
          containers: [
            {
              name: 'unstable-http-server',
              image: 'necior/unstable-http-server:dev',
              imagePullPolicy: 'Always',
              resources: {
                requests: {
                  cpu: '0.001',
                  memory: '3Mi',
                },
                limits: {
                  cpu: '0.100',
                  memory: '10Mi',
                },
              },
              ports: [
                {
                  containerPort: 8080,
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
      name: 'unstable-http-server-service',
    },
    spec: {
      selector: {
        app: 'unstable-http-server',
      },
      ports: [
        {
          protocol: 'TCP',
          port: 80,
          targetPort: app.deployment.spec.template.spec.containers[0].ports[0].containerPort,
        },
      ],
    },
  },

  ingress: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'unstable-http-server-ingress',
    },
    spec: {
      rules: [
        {
          host: private.unstable_http_server_domain,
          http:
            {
              paths: [
                {
                  path: '/',
                  pathType: 'Prefix',
                  backend: {
                    service: {
                      name: app.service.metadata.name,
                      port: {
                        number: app.service.spec.ports[0].port,
                      },
                    },
                  },
                },
              ],
            },
        },
      ],
    },
  },
}
