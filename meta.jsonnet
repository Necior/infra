local private = import 'private.libsonnet';
local links = ['<a href="https://' + domain + '">' + domain + '</a><br/>' for domain in std.sort([
  private.elm_playground_domain,
  private.elm_pomodoro_domain,
  private.blog_domain,
  private.mongo_express_domain,
  private.httpmongo_domain,
  private.unstable_http_server_domain,
  private.homepage_domain,
  private.sssnek_domain,
  private.adminer_domain,
  private.grafana_domain,
])];
local html = '<!doctype html><html lang="en"><title>meta</title><body>' + std.join(' ', links);

{
  local app = self,
  local replicas = 1,

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'meta-deployment',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'meta',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            app: 'meta',
          },
        },
        spec: {
          containers: [
            {
              name: 'meta',
              image: 'nginx:1.21.4',
              imagePullPolicy: 'IfNotPresent',
              command: ['/bin/sh', '-c', 'echo ' + std.base64(html) + ' | base64 -d > /usr/share/nginx/html/index.html && nginx -g daemon\\ off\\;'],
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
      name: 'meta-service',
    },
    spec: {
      selector: {
        app: 'meta',
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
      name: 'meta-ingress',
    },
    spec: {
      tls: [{ hosts: private.domains, secretName: 'domain-cert-tls' }],
      rules: [
        {
          host: private.meta_domain,
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
