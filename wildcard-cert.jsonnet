local private = import 'private.libsonnet';

{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'domain-cert',
  },
  spec: {
    secretName: 'domain-cert-tls',
    dnsNames: private.domains,
    issuerRef: {
      name: 'le-prod-issuer',
      kind: 'Issuer',
    },
  },
}
