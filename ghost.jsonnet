{
  config: {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'ghost-config',
    },
    data: {
      'ghost-config.js': |||
        var path = require('path'),
            config;

        config = {
          development: {
            url: 'http://localhost:2368',
            database: {
              client: 'sqlite3',
              connection: {
                filename: path.join(process.env.GHOST_CONTENT, '/data/ghost-dev.db')
              },
              debug: false
            },
            server: {
              host: '0.0.0.0',
              port: '2368'
            },
            paths: {
              contentPath: path.join(process.env.GHOST_CONTENT, '/')
            }
          }
        };
      |||,
    },
  },

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'ghost',
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          run: 'ghost',
        },
      },
      template: {
        metadata: {
          labels: {
            run: 'ghost',
          },
        },
        spec: {
          containers: [
            {
              name: 'ghost',
              image: 'ghost',
              command: ['sh', '-c', 'cp /ghost-config/ghost-config.js /var/lib/ghost/config.js && /usr/local/bin/docker-entrypoint.sh node current/index.js'],
              volumeMounts: [
                {
                  mountPath: '/ghost-config',
                  name: 'config',
                },
              ],
            },
          ],
          volumes: [
            {
              name: 'config',
              configMap: {
                defaultMode: 420,
                name: 'ghost-config',
              },
            },
          ],
        },
      },
    },
  },
}
