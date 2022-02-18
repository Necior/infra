local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'adminer-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'adminer',
        },
      },
      replicas: replicas,
      strategy: {
        type: 'Recreate',
      },
      template: {
        metadata: {
          labels: {
            app: 'adminer',
          },
        },
        spec: {
          containers: [
            {
              name: 'adminer',
              image: 'adminer:4.8.1',
              imagePullPolicy: 'IfNotPresent',
              env: [
                {
                  name: 'ADMINER_DESIGN',
                  value: 'dracula',
                },
                {
                  name: 'ADMINER_DEFAULT_SERVER',
                  value: 'postgresql-service',
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
      name: 'adminer-service',
    },
    spec: {
      selector: {
        app: 'adminer',
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
      name: 'adminer-ingress',
      annotations: {
        'nginx.ingress.kubernetes.io/auth-type': 'basic',
        'nginx.ingress.kubernetes.io/auth-secret': 'basicauth',
      },
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.adminer_domain,
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
