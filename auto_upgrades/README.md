# auto_upgrades

Настраивает автоматические обновления пакетов.

| ОС | Конфиг | Сервис |
|----|--------|--------|
| Debian/Ubuntu | `apt_auto_upgrades_conf` (vars/) | `unattended-upgrades` |
| AlmaLinux/RHEL | `dnf_automatic_conf` (vars/) | `dnf-automatic.timer` |

---

## Debian/Ubuntu — переменные

| Переменная | Тип | Рендерится как |
|------------|-----|----------------|
| `apt_periodic` | dict | `APT::Periodic::Key "value";` |
| `apt_archives` | dict | `APT::Archives::Key "value";` |
| `apt_update_post_invoke_success` | list | `APT::Update::Post-Invoke-Success { "cmd"; };` |
| `apt_update_pre_invoke` | list | `APT::Update::Pre-Invoke { "cmd"; };` |

Пустой `{}` или `[]` — секция не рендерится.

## AlmaLinux/RHEL — переменные

| Переменная | Секция | По умолчанию |
|------------|--------|-------------|
| `dnf_automatic_commands` | `[commands]` | см. defaults |
| `dnf_automatic_emitters` | `[emitters]` | `emit_via: stdio` |
| `dnf_automatic_email` | `[email]` | `{}` |
| `dnf_automatic_command` | `[command]` | `{}` |
| `dnf_automatic_command_email` | `[command_email]` | `{}` |
| `dnf_automatic_base` | `[base]` | `{}` |

Пустой `{}` — секция не рендерится.

### Ключи `dnf_automatic_commands`

| Ключ | Значения |
|------|---------|
| `upgrade_type` | `security` / `default` |
| `download_updates` | `yes` / `no` |
| `apply_updates` | `yes` / `no` |
| `random_sleep` | секунды (int) |
| `reboot` | `never` / `when-changed` / `always` |
| `reboot_command` | shell-команда |

---

## Примеры

```yaml
# Только скачивать + уведомление на email (RHEL)
dnf_automatic_commands:
  upgrade_type: default
  download_updates: yes
  apply_updates: no
  random_sleep: 360
  reboot: never

dnf_automatic_emitters:
  emit_via: email
  output_width: 80

dnf_automatic_email:
  email_from: ansible@myhost.local
  email_to: admin@myhost.local
  email_host: localhost

# Ограничить кэш + хук после update (Debian)
apt_archives:
  MaxAge: "30"
  MinAge: "2"
  MaxSize: "500"

apt_update_post_invoke_success:
  - "touch /var/lib/apt/periodic/update-success-stamp 2>/dev/null || true"
```
