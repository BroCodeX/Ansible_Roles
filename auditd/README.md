# auditd

Устанавливает auditd и деплоит правила аудита в `/etc/audit/rules.d/hardening.rules`.  
После изменения правил автоматически запускает `augenrules --load` и перезапускает сервис.

## Структура

```
tasks/
├── main.yml      — include_vars + import_tasks
├── install.yml   — установка пакета и включение сервиса
└── rules.yml     — деплой шаблона правил
```

## Переменные (`defaults/main.yml`)

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `audit_rules_path` | `/etc/audit/rules.d/hardening.rules` | Путь к файлу правил |
| `audit_rules` | см. defaults | Список правил auditctl |

Пакет определяется из `vars/`: `auditd` (Debian) / `audit` (RedHat).

## Правила по умолчанию

| Правило | Ключ | Описание |
|---------|------|----------|
| `-w /etc/passwd -p wa` | `identity` | Запись в passwd |
| `-w /etc/shadow -p wa` | `identity` | Запись в shadow |
| `-w /etc/group -p wa` | `identity` | Запись в group |
| `-w /etc/sudoers -p wa` | `sudoers` | Изменение sudoers |
| `-w /etc/sudoers.d -p wa` | `sudoers` | Изменение sudoers.d |
| `-w /etc/ssh/sshd_config -p wa` | `sshd_config` | Изменение конфига SSH |
| `-w /root/.ssh -p wa` | `root_ssh` | Изменение SSH ключей root |
| `-a always,exit -S setuid,setgid (b64/b32)` | `setuid` | Вызовы setuid/setgid |
| `-a always,exit -S open,openat -F exit=-EACCES (b64/b32)` | `access_denied` | Отказы доступа |

## Добавление правила

```yaml
audit_rules:
  - '-w /etc/crontab -p wa -k cron'
  - '-a always,exit -F arch=b64 -S execve -F key=exec'
```

## Проверка активных правил

```bash
auditctl -l
ausearch -k identity    # события по ключу
ausearch -k sudoers
```
