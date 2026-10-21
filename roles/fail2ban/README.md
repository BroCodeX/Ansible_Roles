# fail2ban

Устанавливает fail2ban (Debian/Ubuntu и CentOS/RedHat) и деплоит конфигурацию jail-ов и кастомных фильтров.

## Структура задач (`tasks/`)

| Файл | Назначение |
|------|------------|
| `main.yml` | Точка входа, подключает остальные файлы по порядку |
| `install.yml` | Установка пакета `fail2ban` под Debian-based и RedHat-based ОС (для CentOS дополнительно подключает `epel-release`) |
| `filters.yml` | Деплой кастомных фильтров в `/etc/fail2ban/filter.d/<name>.conf` |
| `jails.yml` | Деплой jail-конфигов в `/etc/fail2ban/jail.d/<name>.local` |
| `service.yml` | Включение и запуск сервиса `fail2ban` |

Поддерживаемые семейства ОС: `Debian`, `RedHat`. При запуске на другой ОС роль завершится с ошибкой.

## Переменные (`defaults/main.yml`)

| Переменная | Описание |
|------------|----------|
| `fail2ban_jails` | Список jail-ов. Каждый item → отдельный файл `<name>.local`. Ключи `options` соответствуют директивам fail2ban без изменений |
| `fail2ban_filters` | Список кастомных фильтров. Каждый item → отдельный файл `<name>.conf`. Ключи `definition` соответствуют директивам секции `[Definition]`; значение может быть строкой или списком строк (многострочный `failregex`) |

## Пример jail-ов

```yaml
fail2ban_jails:
  - name: sshd
    options:
      enabled: true
      port: 22
      filter: sshd
      backend: systemd
      maxretry: 3
      findtime: 5m
      bantime: 1h

  - name: nginx-http-auth
    options:
      enabled: true
      port: http,https
      filter: nginx-http-auth
      logpath: /var/log/nginx/error.log
      maxretry: 5
      bantime: 10m
```

## Пример кастомного фильтра

```yaml
fail2ban_filters:
  - name: custom-app
    definition:
      failregex:
        - ^<HOST> - Failed login for .*$
        - ^<HOST> - Blocked suspicious request .*$
      ignoreregex: ''
```

Jail, использующий этот фильтр, ссылается на него по имени файла (без расширения):

```yaml
fail2ban_jails:
  - name: custom-app
    options:
      enabled: true
      filter: custom-app
      logpath: /var/log/custom-app/access.log
      maxretry: 5
      bantime: 1h
```

## Handlers (`handlers/main.yml`)

Любое изменение jail- или filter-конфига вызывает `notify: restart fail2ban`. Этот топик слушает `validate fail2ban configuration` (`fail2ban-client -t`, штатный флаг проверки конфигурации), которая проверяет корректность итоговой конфигурации и только затем нотифицирует `restart fail2ban service` — фактический перезапуск сервиса. Это предотвращает падение fail2ban с некорректным конфигом.
