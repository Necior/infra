local app = import 'app.libsonnet';
local private = import 'private.libsonnet';

app(
  name='validator',
  image='ghcr.io/validator/validator:21.7.10',
  internal_port=8888,
  domain=private.validator_domain,
  archs=['amd64'],
)
