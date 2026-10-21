# ssh_hardening

Настраивает `/etc/ssh/sshd_config`, выставляет права, делает бэкап.  
Перед рестартом валидирует конфиг через `sshd -t` — если тест не проходит, сервис не перезапускается.

## Переменные (`defaults/main.yml`)

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `ssh_port` | `22` | Порт SSH |
| `ssh_config_path` | `/etc/ssh/sshd_config` | Путь к конфигу |
| `backup_dir` | `/var/backups/hardening` | Директория бэкапов |
| `ssh_settings` | см. defaults | Список `{regexp, line}` для lineinfile |

## Расширение настроек

```yaml
ssh_settings:
  - { regexp: '^#?PermitRootLogin',      line: 'PermitRootLogin no' }
  - { regexp: '^#?PasswordAuthentication', line: 'PasswordAuthentication no' }
  - { regexp: '^#?MaxAuthTries',          line: 'MaxAuthTries 3' }
  - { regexp: '^#?Port',                  line: 'Port 22322' }
```
