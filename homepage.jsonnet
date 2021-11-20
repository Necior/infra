local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'homepage-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'homepage',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'homepage',
          },
        },
        spec: {
          containers: [
            {
              name: 'homepage',
              image: 'nginx:1.21.1',
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
              volumeMounts: [
                {
                  name: app.deployment.spec.template.spec.volumes[0].name,
                  mountPath: '/usr/share/nginx/html',
                  readOnly: true,
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
          volumes: [
            {
              name: app.pvc.metadata.name,
              persistentVolumeClaim: { claimName: app.pvc.metadata.name },
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
      name: 'homepage-service',
    },
    spec: {
      selector: {
        app: 'homepage',
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
      name: 'homepage-ingress',
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.homepage_domain,
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

  pvc: {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'homepage',
    },
    spec: {
      accessModes: ['ReadWriteOnce'],
      storageClassName: 'local-path',
      resources: {
        requests: {
          storage: '300Mi',
        },
      },
    },
  },
}
