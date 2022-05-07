local master_conf = |||
  bind 0.0.0.0
  port 6379

  dir /redis-data
|||;

local slave_conf = |||
  bind 0.0.0.0
  port 6379

  dir .
  slaveof redis-0.redis 6379
|||;

local sentinel_conf = |||
  bind 0.0.0.0
  port 26379

  sentinel monitor redis redis-0.redis 6379 2
  sentinel parallel-syncs redis 1
  sentinel down-after-milliseconds redis 10000
  sentinel failover-timeout redis 20000
|||;

local init_sh = |||
  #!/bin/bash
  if [[ ${HOSTNAME} == 'redis-0' ]]; then
    redis-server /redis-config/master.conf
  else
    redis-server /redis-config/slave.conf
  fi
|||;

local sentinel_sh = |||
  #!/bin/bash
  cp /redis-config-src/*.* /redis-config

  while ! ping -c 1 redis-0.redis; do
    echo 'Waiting for server'
    sleep 1
  done

  redis-sentinel /redis-config/sentinel.conf
|||;

{
  config: {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'redis-config',
    },
    data: {
      'slave.conf': slave_conf,
      'master.conf': master_conf,
      'sentinel.conf': sentinel_conf,
      'init.sh': init_sh,
      'sentinel.sh': sentinel_sh,
    },
  },

  sts: {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      name: 'redis',
    },
    spec: {
      replicas: 3,
      serviceName: 'redis',
      selector: {
        matchLabels: {
          app: 'redis',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'redis',
          },
        },
        spec: {
          containers: [
            {
              command: ['sh', '-c', 'source /redis-config/init.sh'],
              image: 'redis:4.0.11-alpine',
              name: 'redis',
              ports: [{ containerPort: 6379, name: 'redis' }],
              volumeMounts: [
                {
                  mountPath: '/redis-config',
                  name: 'config',
                },
                {
                  mountPath: '/redis-data',
                  name: 'data',
                },
              ],
            },
            {
              command: ['sh', '-c', 'source /redis-config-src/sentinel.sh'],
              image: 'redis:4.0.11-alpine',
              name: 'sentinel',
              volumeMounts: [
                {
                  mountPath: '/redis-config-src',
                  name: 'config',
                },
                {
                  mountPath: '/redis-config',
                  name: 'data',
                },
              ],
            },
          ],
          volumes: [
            {
              configMap: {
                defaultMode: std.parseOctal('420'),
                name: 'redis-config',
              },
              name: 'config',
            },
            {
              emptyDir: {},
              name: 'data',
            },
          ],
        },
      },
    },
  },

  svc: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'redis',
    },
    spec: {
      ports: [
        {
          port: 6379,
          name: 'peer',
        },
      ],
      clusterIP: 'None',
      selector: {
        app: 'redis',
      },
    },
  },
}
