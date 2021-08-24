local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'elm-playground-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'elm-playground',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'elm-playground',
          },
        },
        spec: {
          containers: [
            {
              name: 'elm-playground',
              image: 'necior/elm-playground:dev',
              imagePullPolicy: 'Always',
              resources: {
                requests: {
                  cpu: '0.001',
                  memory: '3Mi',
                },
                limits: {
                  cpu: '0.250',
                  memory: '10Mi',
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
              effect: 'NoExecute',
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
      name: 'elm-playground-service',
    },
    spec: {
      selector: {
        app: 'elm-playground',
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
      name: 'elm-playground-ingress',
    },
    spec: {
      rules: [
        {
          host: private.elm_playground_domain,
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
