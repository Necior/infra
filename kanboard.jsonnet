local app = import 'app.libsonnet';
local private = import 'private.libsonnet';

app(
  name='kanboard',
  image='kanboard/kanboard:v1.2.22',
  internal_port=80,
  domain=private.kanboard_domain,
  archs=['arm64'],
  env=[
    { name: 'DATABASE_URL', value: 'postgres://postgres:' + private.postgresql_postgres_password + '@postgresql-service/kanboard' },
  ],
)
