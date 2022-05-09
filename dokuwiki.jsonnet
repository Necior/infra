local app = import 'app.libsonnet';
local private = import 'private.libsonnet';

app(
  name='dokuwiki',
  image='docker.io/bitnami/dokuwiki:20200729',
  internal_port=8080,
  domain=private.dokuwiki_domain,
  archs=['amd64'],
  persistent_path='/bitnami/dokuwiki',
  env=[
    { name: 'DOKUWIKI_USERNAME', value: 'admin' },
    { name: 'DOKUWIKI_FULL_NAME', value: 'admin' },
    { name: 'DOKUWIKI_PASSWORD', value: private.dokuwiki_password },
    { name: 'DOKUWIKI_EMAIL', value: private.admin_email },
    { name: 'DOKUWIKI_WIKI_NAME', value: 'programowanko wiki' },
  ],
)
