# hardening_packages

Устанавливает базовый набор security-пакетов и включает автообновления.

## Поддерживаемые ОС

| ОС | Пакеты | Autoupdate |
|----|--------|------------|
| Debian/Ubuntu | auditd, fail2ban, lynis, unattended-upgrades, logwatch | unattended-upgrades |
| AlmaLinux/RHEL | audit, fail2ban, lynis, dnf-automatic, logwatch | dnf-automatic.timer |

## Переменные

Пакеты и имя сервиса автообновлений задаются в `vars/Debian.yml` и `vars/RedHat.yml`.  
Переопределяй напрямую в этих файлах.

## Пример

```yaml
- hosts: all
  roles:
    - role: hardening_packages
```
