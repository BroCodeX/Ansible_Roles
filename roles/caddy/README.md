# caddy

Installs [Caddy](https://caddyserver.com/docs/install) from the official repositories and manages one config file per domain in `/etc/caddy/conf.d`.

| OS family | Source |
|-----------|--------|
| Debian / Ubuntu | Cloudsmith `caddy/stable` apt repo |
| RedHat (AlmaLinux, Rocky, RHEL, CentOS) | COPR `@caddy/caddy` |

The main `/etc/caddy/Caddyfile` is generated and ends with `import /etc/caddy/conf.d/*.caddy`.
The config is validated (`caddy validate`) before the service is reloaded.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `caddy_package_state` | `present` | `present` / `latest` |
| `caddy_global_options` | `[]` | Lines for the global options block |
| `caddy_sites` | `[]` | List of sites (see below) |
| `caddy_log_dir` | `/var/log` | Log for each site: `<dir>/<domain>.log` |
| `caddy_log_format` | `json` | `json` / `console` (per-site override: `log_format`) |
| `caddy_log_mode` | `0640` | Log file mode |
| `caddy_log_roll_size` / `caddy_log_roll_keep` | `100MiB` / `10` | Built-in rotation |

### Site fields

| Field | Description |
|-------|-------------|
| `domain` | Required. Site address, also the file/log name |
| `aliases` | Extra addresses for the same site |
| `root` | Static site root (`file_server`) |
| `reverse_proxy` | Upstream, used instead of `root` |
| `encode` | `true` by default |
| `log_format` | Overrides `caddy_log_format` |
| `extra_config` | Raw Caddyfile lines added to the site block |
| `basic_auth` | `users` (required), `path` (matcher, default whole site), `realm` |
| `state` | `absent` removes the site config (log file is kept) |

### Basic auth

Users take either a plain `password` (hashed with bcrypt by the role) or a ready `password_hash` from `caddy hash-password`.
The bcrypt salt is derived from user + domain, so reruns stay idempotent. Plain passwords need `passlib` on the controller.

```bash
ansible-vault encrypt_string 'S3cret' --name vault_example_password
```

## Example

```yaml
- hosts: web
  roles:
    - role: caddy
      vars:
        caddy_global_options:
          - email admin@example.com
        caddy_sites:
          - domain: example.com
            aliases: [www.example.com]
            root: /var/www/example.com
          - domain: app.example.com
            reverse_proxy: 127.0.0.1:8080
            basic_auth:
              path: /admin/*
              users:
                - name: admin
                  password: "{{ vault_example_password }}"
```

## Notes

- Caddy runs as `caddy`, which cannot create files in `/var/log`. The role pre-creates each log file owned by `caddy`.
- On SELinux hosts, check that the `caddy` domain may write to the files in `caddy_log_dir`. The package policy targets `/var/log/caddy`.
