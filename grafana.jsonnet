local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'grafana-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'grafana',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'grafana',
          },
        },
        spec: {
          containers: [
            {
              name: 'grafana',
              image: 'grafana/grafana:8.3.3',
              imagePullPolicy: 'IfNotPresent',
              resources: {
                requests: {
                  cpu: '1m',
                  memory: '10Mi',
                },
                limits: {
                  cpu: '1000m',
                  memory: '1000Mi',
                },
              },
              volumeMounts: [
                {
                  name: app.deployment.spec.template.spec.volumes[0].name,
                  mountPath: '/var/lib/grafana',
                },
              ],
              ports: [
                {
                  containerPort: 3000,
                },
              ],
            },
          ],
          volumes: [
            {
              name: app.pvc.metadata.name,
              persistentVolumeClaim: { claimName: app.pvc.metadata.name },
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
      name: 'grafana-service',
    },
    spec: {
      selector: {
        app: 'grafana',
      },
      ports: [
        {
          protocol: 'TCP',
          port: 3000,
          targetPort: app.deployment.spec.template.spec.containers[0].ports[0].containerPort,
        },
      ],
    },
  },

  pvc: {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'grafana-storage',
    },
    spec: {
      accessModes: [
        'ReadWriteOnce',
      ],
      storageClassName: 'local-path',
      resources: {
        requests: {
          storage: '2Gi',
        },
      },
    },
  },

  ingress: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'grafana-ingress',
      annotations: {
        'nginx.ingress.kubernetes.io/auth-type': 'basic',
        'nginx.ingress.kubernetes.io/auth-secret': 'basicauth',
      },
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.grafana_domain,
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
