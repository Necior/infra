# personal-infra

My personal infrastructure.
Currently I use a managed Kubernetes engine (namely GKE).

All resources are stored in this repository.
Since YAML is a nightmare, I use [Jsonnet](https://jsonnet.org/), which is a JSON superset with variables, functions etc.
To update cluster resources, I use [`kubecfg`](https://github.com/bitnami/kubecfg).

## Cheat sheet

* `nix-shell` - start an interactive shell with needed tools (it also creates a `k` alias for `kubectl`);
* `kubecfg update pastebin.jsonnet` - update Kubernetes resources.

