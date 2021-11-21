local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'elm-pomodoro-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'elm-pomodoro',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'elm-pomodoro',
          },
        },
        spec: {
          containers: [
            {
              name: 'elm-pomodoro',
              image: 'necior/elm-pomodoro:0.1.0',
              imagePullPolicy: 'IfNotPresent',
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
      name: 'elm-pomodoro-service',
    },
    spec: {
      selector: {
        app: 'elm-pomodoro',
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
      name: 'elm-pomodoro-ingress',
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.elm_pomodoro_domain,
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
