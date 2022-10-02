local app = import 'app.libsonnet';
local private = import 'private.libsonnet';

app(
  name='etherpad',
  image='etherpad/etherpad:1.8.18',
  internal_port=9001,
  domain=private.etherpad_domain,
  archs=['amd64'],
  persistent_path='/opt/etherpad-lite/var/',
)
