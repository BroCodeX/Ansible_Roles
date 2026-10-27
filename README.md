# Ansible_Roles

Набор Ansible-ролей и плейбуков для настройки серверов: hardening, базовая конфигурация, web, контейнеры, логирование, Vault, бэкапы.

## Документация

| Документ | О чём |
|---|---|
| [README_Hardening.md](README_Hardening.md) | Роли hardening, теги, переменные |
| [README_Roles.md](README_Roles.md) | Остальные роли (не hardening) |
| [README_CICD.md](README_CICD.md) | Запуск плейбуков через GitLab CI/CD |
| [CHANGELOG.md](CHANGELOG.md) | История изменений |

## Требования

| Требование | Версия / Примечание |
|---|---|
| Ansible | ≥ 2.12 |
| ОС целевых хостов | Debian/Ubuntu, AlmaLinux/RHEL |
| SSH-пользователь | `ansible` (см. [ansible.cfg](ansible.cfg)), `become` |
| Galaxy-роли | `ansible-galaxy install -r requirements.yml` |

## Структура

```
.
├── .gitlab-ci.yml
├── ansible.cfg          # roles_path = roles:.ansible/roles
├── requirements.yml
├── inventory/hosts.yml  # не в репозитории: создайте свой
├── playbooks/
└── roles/
```

## Плейбуки

Каждый плейбук объединяет роли по назначению и работает с отдельной группой инвентори.

| Плейбук | Группа хостов | Роли |
|---|---|---|
| [hardening.yml](playbooks/hardening.yml) | `all` | `hardening_packages`, `ssh_hardening`, `password_policy`, `network_hardening`, `fail2ban`, `logrotate`, `auto_upgrades`, `auditd` |
| [base.yml](playbooks/base.yml) | `base_hosts` | `common`, `users`, `firewalld` |
| [web.yml](playbooks/web.yml) | `caddy_hosts` | `caddy` |
| [containers.yml](playbooks/containers.yml) | `docker_hosts`, `ldap_hosts` | `geerlingguy.docker`, `docker-compose`, `ldap` |
| [logging.yml](playbooks/logging.yml) | `elastic_hosts`, `vector_hosts` | `elastic_stack`, `vector` |
| [vault.yml](playbooks/vault.yml) | `vault_hosts` | `vault` |
| [backup.yml](playbooks/backup.yml) | `vault_hosts`, `mongodb_hosts` | `vault_backup`, `mongodb_backup` |
| [devops.yml](playbooks/devops.yml) | `ops_hosts` | `ops`, `k8s-manifest` |

## Запуск

```bash
# Dry-run с diff, затем реальный прогон
ansible-playbook playbooks/web.yml -i inventory/hosts.yml -C -D
ansible-playbook playbooks/web.yml -i inventory/hosts.yml -D

# Выборочно по группе и тегу
ansible-playbook playbooks/hardening.yml -i inventory/hosts.yml --limit web01 --tags ssh
```

Секреты (Vault-токены, пароли S3/alertmanager/LDAP) храните в `ansible-vault`; в CI включается флагом `has_vault`.
