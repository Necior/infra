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
}
