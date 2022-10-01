local mongodb = import 'mongodb.jsonnet';
local private = import 'private.libsonnet';

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'korova-deployment',
    },
    spec: {
      strategy: {
        type: 'Recreate',
      },
      selector: {
        matchLabels: {
          app: 'korova',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'korova',
          },
        },
        spec: {
          terminationGracePeriodSeconds: 5,
          containers: [
            {
              name: 'korova',
              image: 'necior/korova:0.1.14',
              imagePullPolicy: 'IfNotPresent',
              env: [
                { name: 'KOROVA_MONGODB_CONNECTION_STRING', value: 'mongodb://' + mongodb.service.metadata.name },
                { name: 'KOROVA_MONGODB_DB', value: 'httpmongodb' },
                { name: 'KOROVA_MONGODB_COLLECTION', value: 'httpmongocollection' },
              ],
              envFrom: [{ secretRef: { name: app.secret.metadata.name } }],
              resources: {
                requests: {
                  cpu: '0.001',
                  memory: '5Mi',
                },
                limits: {
                  cpu: '1.0',
                  memory: '10Mi',
                },
              },
            },
          ],
          affinity: {
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [
                  {
                    matchExpressions: [
                      {
                        key: 'kubernetes.io/arch',
                        operator: 'In',
                        values: [
                          'amd64',
                        ],
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

  secret: {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: {
      name: 'korova-secrets',
    },
    data: {
      KOROVA_TOKEN: private.korova_token,
      KOROVA_OWM_APIKEY: private.korova_owm_apikey,
    },
  },
}
