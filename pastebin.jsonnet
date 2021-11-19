local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'pastebin-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'pastebin',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'pastebin',
          },
        },
        spec: {
          containers: [
            {
              name: 'pastebin',
              image: 'necior/pastebin:dev2',
              imagePullPolicy: 'Always',
              env: [
                {
                  name: 'PASTEBIN_HOST',
                  value: '0.0.0.0',
                },
              ],
              resources: {
                requests: {
                  cpu: '0.001',
                  memory: '1Mi',
                },
                limits: {
                  cpu: '0.250',
                  memory: '10Mi',
                },
              },
              ports: [
                {
                  containerPort: 2137,
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
      name: 'pastebin-service',
    },
    spec: {
      selector: {
        app: 'pastebin',
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
      name: 'pastebin-ingress',
      annotations: {
        'nginx.ingress.kubernetes.io/auth-type': 'basic',
        'nginx.ingress.kubernetes.io/auth-secret': 'basicauth',

      },
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.pastebin_domain,
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
