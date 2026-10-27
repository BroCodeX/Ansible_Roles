# Роли (без hardening)

Роли hardening описаны в [README_Hardening.md](README_Hardening.md). Общий обзор — в [README.md](README.md).

## Роли

| Роль | Плейбук | Теги | Что делает |
|---|---|---|---|
| `common` | [base.yml](playbooks/base.yml) | `common` | Базовые пакеты, таймзона, sysctl, ulimit, swap, `/etc/hosts`, s3cmd |
| `users` | [base.yml](playbooks/base.yml) | `users` | Пользователи, SSH-ключи и sudo через `/etc/sudoers.d` |
| `firewalld` | [base.yml](playbooks/base.yml) | `firewalld`, `check_unmanaged` | Зоны, сервисы и правила firewalld |
| `caddy` | [web.yml](playbooks/web.yml) | `caddy` | Установка Caddy, конфиг на домен в `/etc/caddy/conf.d`, валидация перед reload |
| `docker-compose` | [containers.yml](playbooks/containers.yml) | `docker_compose` | Деплой compose-проектов из шаблонов, очистка неуправляемых проектов |
| `ldap` | [containers.yml](playbooks/containers.yml) | `ldap`, `ldif` | OpenLDAP в compose, импорт LDIF |
| `elastic_stack` | [logging.yml](playbooks/logging.yml) | `elastic_stack`, `install_elastic`, `secure_elastic`, `config_elastic` | Elasticsearch, Kibana, APM, exporter |
| `vector` | [logging.yml](playbooks/logging.yml) | `vector` | Установка и конфиг Vector, systemd unit |
| `vault` | [vault.yml](playbooks/vault.yml) | `vault`, `preinstall`, `installation` | Установка HashiCorp Vault (репозиторий или zip), TLS |
| `vault_backup` | [backup.yml](playbooks/backup.yml) | `vault_backup` | Raft-снапшот Vault по cron, выгрузка в S3, retention |
| `mongodb_backup` | [backup.yml](playbooks/backup.yml) | `mongodb_backup` | Пользователь backup, дамп MongoDB по cron в S3, retention |
| `ops` | [devops.yml](playbooks/devops.yml) | `ops`, `ansible`, `helm`, `helmfile`, `sops`, `kubectl` | Инструменты DevOps-инстанса: ansible, helm, helmfile, sops, kubectl, terraform, aws, openstack |
| `k8s-manifest` | [devops.yml](playbooks/devops.yml) | `k8s_manifest`, `validate`, `vault`, `render`, `deploy` | Генерация k8s-манифестов, секреты из Vault |

Внешняя роль `geerlingguy.docker` (7.4.7) ставится из [requirements.yml](requirements.yml) и запускается в [containers.yml](playbooks/containers.yml) с тегом `docker`.

## Безопасность

- Роли `vault_backup`, `mongodb_backup`, `ldap`, `elastic_stack`, `k8s-manifest` требуют паролей/токенов — задавайте их только через `ansible-vault`, не в `defaults/`.
- `elastic_stack`: сертификаты генерируются на одной ноде и на остальные не синхронизируются — копируются вручную.
- `firewalld`, `users` меняют доступ к хосту: сначала `-C -D`.

<details>
<summary>Ключевые переменные</summary>

| Роль | Переменные |
|---|---|
| `common` | `base_packages`, `tz_name`, `sysctl_parameters`, `pam_limits`, `swap_enable` |
| `users` | `users_users` |
| `firewalld` | `firewalld_config_defaultzone`, `firewalld_additional_zones`, `firewalld_configuration` |
| `caddy` | `caddy_package_state`, `caddy_global_options`, `caddy_log_dir` |
| `docker-compose` | `docker_compose_project_name`, `docker_compose_project_path`, `docker_compose_files`, `docker_compose_state` |
| `ldap` | `ldap_domain`, `ldap_base_dn`, `ldap_admin_password`, `ldap_tls_enabled` |
| `elastic_stack` | `elasticsearch_version`, `elasticsearch_heap_size`, `elasticsearch_cluster_name` |
| `vector` | `vector_version`, `vector_config_file`, `vector_api_enabled` |
| `vault` | `vault_version`, `vault_architecture` |
| `vault_backup` | `vault_addr`, `s3_bucket`, `s3_path`, `cron_jobs`, `retention_policy` |
| `mongodb_backup` | `mongodb_backup_username`, `mongodb_host`, `s3_bucket`, `retention_policy` |
| `ops` | `ansible_install_version`, `helm_version`, `helmfile_version` |
| `k8s-manifest` | `k8s_manifest_name`, `k8s_manifest_image`, `k8s_manifest_kinds`, `k8s_manifest_deploy_kube` |

Полный список — в `roles/<role>/defaults/main.yml` и README роли.

</details>
