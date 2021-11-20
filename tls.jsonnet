local private = import 'private.libsonnet';

{
  local tls = self,

  secret: {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: {
      name: 'digitalocean-dns',
    },
    data: {
      'access-token': private.digitalocean_apikey,
    },
  },

  issuer: {
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
                  name: tls.secret.metadata.name,
                  key: 'access-token',
                },
              },
            },
          },
        ],
      },
    },
  },

  certificate: {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Certificate',
    metadata: {
      name: 'domain-cert',
    },
    spec: {
      secretName: 'domain-cert-tls',
      dnsNames: private.domains,
      issuerRef: {
        name: tls.issuer.metadata.name,
        kind: 'Issuer',
      },
    },
  },
}
