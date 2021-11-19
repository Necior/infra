local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'mongo-express-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'mongo-express',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'mongo-express',
          },
        },
        spec: {
          containers: [
            {
              name: 'mongo-express',
              image: 'mongo-express:latest',
              imagePullPolicy: 'Always',
              env: [
                {
                  name: 'ME_CONFIG_MONGODB_SERVER',
                  value: 'mongodb-service',
                },
              ],

              resources: {
                requests: {
                  cpu: '0.001',
                  memory: '3Mi',
                },
                limits: {
                  cpu: '0.250',
                  memory: '100Mi',
                },
              },
              ports: [
                {
                  containerPort: 8081,
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
      name: 'mongo-express-service',
    },
    spec: {
      selector: {
        app: 'mongo-express',
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
      name: 'mongo-express-ingress',
      annotations: {
        'nginx.ingress.kubernetes.io/auth-type': 'basic',
        'nginx.ingress.kubernetes.io/auth-secret': 'basicauth',
      },
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.mongo_express_domain,
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
