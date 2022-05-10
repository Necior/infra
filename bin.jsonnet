local app = import 'app.libsonnet';
local private = import 'private.libsonnet';

app(
  name='privatebin',
  image='privatebin/nginx-fpm-alpine:1.4.0',
  internal_port=8080,
  domain=private.privatebin_domain,
  archs=['amd64', 'arm64'],
  persistent_path='/srv/data',
)
