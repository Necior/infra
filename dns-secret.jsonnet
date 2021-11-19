local private = import 'private.libsonnet';

{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'digitalocean-dns',
  },
  data: {
    'access-token': private.digitalocean_apikey,
  },
}
