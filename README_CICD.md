# 🚀 Ansible Universal GitLab Deploy

Унифицированная система развертывания инфраструктуры через GitLab CI/CD с использованием Ansible. Позволяет запускать различные playbooks с гибкой параметризацией, проверкой изменений и безопасностью через Vault.

## 📋 Возможности

- ✅ **Несколько playbooks**: hardening, base, web, containers, logging, vault, backup, devops
- ✅ **Гибкая параметризация**: выбор целевых хостов, тегов и доп. аргументов
- ✅ **Двухэтапная проверка**: сухой прогон (check) перед реальным развертыванием (deploy)
- ✅ **Безопасность**: поддержка SSH ключей и Ansible Vault
- ✅ **Ручная аппровация**: управление через веб-интерфейс GitLab
- ✅ **RBAC**: развертывание с правами администратора (become)

## 🛠️ Требования

- Docker образ с Ansible: `$CI_REGISTRY/project/infra/docker-images/ansible:latest`
- SSH приватный ключ (переменная `ANSIBLE_SSH_PRIVATE_KEY`)
- Known hosts (переменная `SSH_KNOWN_HOSTS`, base64-закодированные)
- Опционально: Ansible Vault пароль (`ANSIBLE_VAULT_PASSWORD_FILE`)
- Инвентори файл: `inventory/hosts.yml`

## 📝 Входные параметры

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|---------|
| `playbook` | string | `hardening` | Playbook из `playbooks/`: `hardening`, `base`, `web`, `containers`, `logging`, `vault`, `backup`, `devops` |
| `limit` | string | `all` | Ограничение на хосты/группы (разделены запятыми) |
| `tags` | string | `all` | Теги задач (разделены запятыми) |
| `extra_args` | string | `` | Дополнительные аргументы для `ansible-playbook` |
| `has_vault` | boolean | `false` | Использовать `--vault-password-file` |

## 🚀 Как использовать

### Через веб-интерфейс GitLab

1. Перейти в **CI/CD → Pipelines**
2. Нажать **Run pipeline**
3. Выбрать ветку (обычно `master`)
4. Заполнить параметры:
   - **playbook**: выбрать нужный playbook
   - **limit**: указать хосты/группы
   - **tags**: указать теги для выполнения
   - **extra_args**: добавить доп. опции (например, `-vv` для verbose)
   - **has_vault**: включить если нужен Vault

### Примеры

#### Hardening на группу хостов
```
playbook: hardening
limit: all
tags: ssh,auditd
extra_args: -vv
has_vault: false
```

#### Бэкап Vault с Vault-паролем
```
playbook: backup
limit: vault_hosts
tags: vault_backup
extra_args:
has_vault: true
```

#### Caddy на web-хосты
```
playbook: web
limit: caddy_hosts
tags: caddy
extra_args: --diff
has_vault: false
```

## 📊 Pipeline этапы

### 1️⃣ Check (Проверка)

- **Описание**: Сухой прогон с флагом `-C -D` (check mode + diff)
- **Когда запускается**:
  - На merge request в `master` (вручную)
  - На `master` при изменении определенных файлов (автоматически)
  - На `master` (вручную)
- **Результат**: Показывает, какие изменения будут внесены без фактического их применения

```yaml
ansible-playbook ${ANSIBLE_ARGS} playbooks/<playbook>.yml -C -D --become
```

### 2️⃣ Deploy (Развертывание)

- **Описание**: Реальное развертывание конфигурации
- **Когда запускается**: После успешного завершения Check
- **Условие**: На `master` (вручную)
- **Результат**: Применяет изменения на целевых хостах

```yaml
ansible-playbook ${ANSIBLE_ARGS} playbooks/<playbook>.yml -D --become
```

## 🔐 Переменные окружения

```bash
# Обязательные
ANSIBLE_SSH_PRIVATE_KEY      # SSH ключ (base64-закодированный)
SSH_KNOWN_HOSTS              # Known hosts (base64-закодированный)

# Опциональные
ANSIBLE_VAULT_PASSWORD_FILE  # Путь к файлу пароля Vault
```

## 📦 Структура проекта

```
.
├── .gitlab-ci.yml           # Конфигурация CI/CD
├── inventory/
│   └── hosts.yml            # Инвентори с хостами/группами
├── ansible.cfg              # roles_path, callbacks
├── requirements.yml         # Galaxy-зависимости
├── playbooks/               # Playbooks (см. README.md)
│   ├── hardening.yml
│   ├── base.yml  web.yml  containers.yml
│   └── logging.yml  vault.yml  backup.yml  devops.yml
└── roles/                   # Ansible roles
```

## 🎯 Правила и триггеры

- ✅ Запуск на `master` ветке (основная работа)
- ✅ Запуск на merge request в `master` (только check, вручную)
- ✅ Автоматический запуск при изменении критических файлов
- ✅ Предотвращение дублирования (no MR when branch has open requests)

## ⚙️ Advanced опции

### Verbose режим
```
extra_args: -vv
```

### Синтаксическая проверка без выполнения
```
extra_args: --syntax-check
```

### Разница в файлах
```
extra_args: --diff
```

### Пропуск определенных тегов
```
extra_args: --skip-tags dangerous
```

## 🔧 Техническая информация

- **Агент**: dev2
- **Образ**: Custom Ansible Docker image
- **SSH**: Использует ssh-agent для управления ключами
- **Режим**: Все команды выполняются с флагом `--become` (sudo)
- **Цвет**: ANSIBLE_FORCE_COLOR включен для лучшей читаемости

## 📚 Дополнительные ресурсы

- [Ansible документация](https://docs.ansible.com/)
- [GitLab CI/CD документация](https://docs.gitlab.com/ee/ci/)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

## 📞 Поддержка

При возникновении проблем проверьте:
1. Наличие и корректность SSH ключа
2. Актуальность Known hosts
3. Наличие инвентори файла `inventory/hosts.yml`
4. Правильность синтаксиса playbooks
5. Наличие необходимых прав доступа на целевых хостах
