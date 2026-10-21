# DevSecOps Ansible Hardening

Ansible-роли для базового hardening Linux-серверов (Debian/Ubuntu, RHEL/CentOS).  
Запускаются единым плейбуком `hardening.yml`.

## Роли

| Роль | Что делает |
|------|-----------|
| `hardening_packages` | Устанавливает auditd, fail2ban, lynis и др. |
| `ssh_hardening` | Настраивает `/etc/ssh/sshd_config`: отключает root login, парольную аутентификацию, ограничивает сессии |
| `password_policy` | Hardening `/etc/login.defs` + деплоит `pwquality.conf`, бэкап системных файлов |
| `network_hardening` | nftables ruleset (stateful firewall) + sysctl-параметры для сети и ядра |
| `fail2ban` | Защита от брутфорса SSH через fail2ban |
| `logrotate` | Ротация логов |
| `auto_upgrades` | Автоматические security-обновления (unattended-upgrades / dnf-automatic) |
| `auditd` | Правила аудита: изменения passwd/shadow/sudoers/sshd_config, setuid-вызовы, отказы доступа |

## Запуск

```bash
# Полный hardening
ansible-playbook hardening.yml -i inventory

# Выборочно по тегу
ansible-playbook hardening.yml -i inventory --tags ssh
ansible-playbook hardening.yml -i inventory --tags sysctl,auditd

# Пропустить роль
ansible-playbook hardening.yml -i inventory --skip-tags logrotate
```

## Теги

`packages` · `ssh` · `password_policy` · `nftables` · `sysctl` · `network_hardening` · `fail2ban` · `logrotate` · `auto_upgrades` · `auditd`

## Переменные

Переопределяются в `group_vars/all.yml`. Дефолты — в `<role>/defaults/main.yml`.

```yaml
ssh_port: 22
backup_dir: /var/backups/hardening
nftables_web_enabled: false
```

## Полезные ссылки

| Инструмент | Описание | Документация |
|------------|----------|--------------|
| `chkrootkit` | Проверяет систему на известные rootkit и подозрительные системные файлы. | https://chkrootkit.org/ |
| `rkhunter` | Ищет руткиты, аномальные права, подозрительные setuid/setgid-файлы и world-writable каталоги. | https://rkhunter.sourceforge.net/ |
| `aide` | FIM-инструмент для создания баз данных файловой целостности и обнаружения изменений. | https://aide.github.io/ |
| `debsums` | Проверяет целостность установленных пакетов Debian/Ubuntu по контрольным суммам. | https://manpages.debian.org/stretch/debsums/debsums.1.en.html |
| `Lynis` | Мощный инструмент аудита безопасности Linux-систем с рекомендациями по hardening. | https://cisofy.com/lynis/ |
| `Trivy` | Сканер уязвимостей для контейнеров, образов, файловой системы и инфраструктуры. | https://aquasecurity.github.io/trivy/ |
| `OpenSCAP` | Фреймворк для проверки соответствия стандартам безопасности и профильной аудита. | https://www.open-scap.org/ |
