local private = import 'private.libsonnet';

{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Issuer',
  metadata: {
    name: 'le-prod-issuer',
  },
  spec: {
    acme: {
      email: private.admin_email,
      server: 'https://acme-v02.api.letsencrypt.org/directory',
      privateKeySecretRef: {
        name: 'le-prod-issuer-account-key',
      },
      solvers: [
        {
          dns01: {
            digitalocean: {
              tokenSecretRef: {
                name: 'digitalocean-dns',
                key: 'access-token',
              },
            },
          },
        },
      ],
    },
  },
}
