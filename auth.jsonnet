local private = import 'private.libsonnet';

{
  secret: {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: {
      name: 'basicauth',
    },
    data: {
      users: private.basic_auth_users,
    },
  },
  middleware: {
    apiVersion: 'traefik.containo.us/v1alpha1',
    kind: 'Middleware',
    metadata: {
      name: 'onlyadmin',
    },
    spec: {
      basicAuth: {
        secret: 'basicauth',
        removeHeader: true,
      },
    },
  },
}
