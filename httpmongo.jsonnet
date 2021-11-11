local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'httpmongo-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'httpmongo',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'httpmongo',
          },
        },
        spec: {
          containers: [
            {
              name: 'httpmongo',
              image: 'necior/httpmongo:dev',
              command: ['gunicorn'],
              args: ['--bind', '0.0.0.0:80', 'app:app'],
              imagePullPolicy: 'Always',
              env: [
                {
                  name: 'HTTPMONGO_MONGODB_HOST',
                  value: 'mongodb-service',
                },
              ],
              resources: {
                requests: {
                  cpu: '0.001',
                  memory: '20Mi',
                },
                limits: {
                  cpu: '0.250',
                  memory: '200Mi',
                },
              },
              ports: [
                {
                  containerPort: 80,
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
      name: 'httpmongo-service',
    },
    spec: {
      selector: {
        app: 'httpmongo',
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
      name: 'httpmongo-ingress',
    },
    spec: {
      rules: [
        {
          host: private.httpmongo_domain,
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
