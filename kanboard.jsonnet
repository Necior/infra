local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'kanboard-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'kanboard',
        },
      },
      replicas: replicas,
      strategy: {
        type: 'Recreate',
      },
      template: {
        metadata: {
          labels: {
            app: 'kanboard',
          },
        },
        spec: {
          containers: [
            {
              name: 'kanboard',
              image: 'kanboard/kanboard:v1.2.22',
              imagePullPolicy: 'IfNotPresent',
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
              env: [
                {
                  name: 'DATABASE_URL',
                  value: 'postgres://postgres:' + private.postgresql_postgres_password + '@postgresql-service/kanboard',
                },
              ],
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
      name: 'kanboard-service',
    },
    spec: {
      selector: {
        app: 'kanboard',
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
      name: 'kanboard-ingress',
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.kanboard_domain,
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
