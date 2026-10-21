# k8s-manifest

Render plain Kubernetes manifests from role variables. Optionally pull secrets
from HashiCorp Vault (via the `community.hashi_vault` lookup plugin) at
generation time and bake them into a `Secret` that the workload consumes.

## What it does

`tasks/main.yml` runs four includes:

1. `validate.yml` — assert the inputs are sane.
2. `vault_secrets.yml` — read KV v2 and/or dynamic secrets from Vault (only when
   `k8s_manifest_vault_enabled`).
3. `render.yml` — write one `<kind>.yaml` file per entry in
   `k8s_manifest_kinds` into `k8s_manifest_output_path`.
4. `deploy.yml` — apply the rendered manifests to the cluster (only when
   `k8s_manifest_deploy_kube`).

Supported kinds: `deployment`, `service`, `ingress`, `secret`, `configmap`,
`serviceaccount`. Add a kind by dropping a `templates/<kind>.yaml.j2` file and
listing it in `k8s_manifest_supported_kinds` (`tasks/validate.yml`).

## Key variables

See `defaults/main.yml` for the full list. Highlights:

| Variable | Purpose |
| --- | --- |
| `k8s_manifest_name` | RFC1123 base name (required) |
| `k8s_manifest_namespace` | Target namespace |
| `k8s_manifest_kinds` | List of manifests to render |
| `k8s_manifest_output_path` | Where the YAML is written |
| `k8s_manifest_image` | Container image for the Deployment |
| `k8s_manifest_env_from_secret` | Load the Secret into the container as env |

### Vault

All Vault settings live in `defaults/main.yml`:

| Variable | Purpose |
| --- | --- |
| `k8s_manifest_vault_enabled` | Master switch |
| `k8s_manifest_vault_addr` | Vault URL |
| `k8s_manifest_vault_token` | Token (defaults to `$VAULT_TOKEN`) |
| `k8s_manifest_vault_kv_*` | Static KV v2 read (`mount`, `path`, `keys`) |
| `k8s_manifest_vault_dynamic_*` | Dynamic lease read (`mount`, `role`, `keys`) |

Vault-sourced values are merged over `k8s_manifest_secret_data` (Vault wins) and
rendered into the `Secret`. With `k8s_manifest_env_from_secret: true` they reach
the container as environment variables.

### Deploy

| Variable | Purpose |
| --- | --- |
| `k8s_manifest_deploy_kube` | Master switch; apply manifests after rendering (default `false`) |
| `k8s_manifest_kubeconfig_source` | Where to read the kubeconfig from: `env` (default) or `vault` |
| `k8s_manifest_kubeconfig` | (`env` source) path to a base64-encoded kubeconfig file, defaults to the `KUBECONFIG` env var |
| `k8s_manifest_kubeconfig_vault_mount` / `_path` / `_key` | (`vault` source) KV v2 mount, path, and secret key holding the base64 kubeconfig |
| `k8s_manifest_kubecontext` | Context to use from the kubeconfig (empty = current-context) |

`deploy.yml` reads the base64 kubeconfig from the chosen source (the `vault`
source reuses the `k8s_manifest_vault_*` connection settings above), decodes
it to a temp file, applies every rendered `<kind>.yaml` with
`kubernetes.core.k8s`, removes the temp file, then removes the rendered
manifests directory (`k8s_manifest_output_path`) once the apply succeeds.

## Requirements

```bash
ansible-galaxy collection install -r requirements.yml   # community.hashi_vault, kubernetes.core
pip install hvac kubernetes
export VAULT_TOKEN=<token>
export KUBECONFIG=<path to base64-encoded kubeconfig>   # only if k8s_manifest_deploy_kube: true
```
