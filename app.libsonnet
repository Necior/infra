local private = import 'private.libsonnet';

local simple_app(
  name,
  image,
  internal_port,
  domain,
  archs,
  replicas=1,
  external_port=80,
  persistent_path=null,
  env=[],
      ) = {
  assert std.length(archs) == 1 || std.length(archs) == 2 : 'You must provide 1 or 2 architectures, not ' + std.length(archs),
  assert archs[0] == 'arm64' || archs[0] == 'amd64' : 'Invalid architecture: ' + archs[0],
  assert std.length(archs) == 1 || archs[1] == 'arm64' || archs[1] == 'amd64' : 'Invalid architecture: ' + archs[1],
  assert persistent_path == null || replicas <= 1 : 'There is no support for multiple replicas with persistence',

  local app = self,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: name,
    },
    spec: {
      selector: {
        matchLabels: {
          app: name,
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: name,
          },
        },
        spec: {
          containers: [
            {
              name: name,
              image: image,
              imagePullPolicy: 'IfNotPresent',
              env: env,
              volumeMounts: if (persistent_path != null) then [
                {
                  name: app.deployment.spec.template.spec.volumes[0].name,
                  mountPath: persistent_path,
                },
              ] else [],
              ports: [
                {
                  containerPort: internal_port,
                },
              ],
            },
          ],
          volumes: if (persistent_path != null) then [
            {
              name: app.pvc.metadata.name,
              persistentVolumeClaim: { claimName: app.pvc.metadata.name },
            },
          ] else [],
          affinity: {
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [
                  {
                    matchExpressions: [
                      {
                        key: 'kubernetes.io/arch',
                        operator: 'In',
                        values: archs,
                      },
                    ],
                  },
                ],
              },
            },
          },
        },
      },
    },
  },

  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: name,
    },
    spec: {
      selector: {
        app: name,
      },
      ports: [
        {
          protocol: 'TCP',
          port: external_port,
          targetPort: app.deployment.spec.template.spec.containers[0].ports[0].containerPort,
        },
      ],
    },
  },

  ingress: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: name,
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: domain,
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

  pvc: if (persistent_path != null) then {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: name + '-storage',
    },
    spec: {
      accessModes: [
        'ReadWriteOnce',
      ],
      storageClassName: 'no-autoremove',
      resources: {
        requests: {
          /*
            2Gi should be enough for everyone.

            On a serious note, though, `local-path` storageClass doesn't enforce storage limits
            so it's not neccessary to provide a sensible value below.
          */
          storage: '2Gi',
        },
      },
    },
  } else {},
};
simple_app
