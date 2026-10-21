# logrotate

Деплоит конфиги logrotate в `/etc/logrotate.d/` и опционально почасовой cron.

## Переменные (`defaults/main.yml`)

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `logrotate_config` | `[]` | Список конфигов для деплоя |
| `logrotate_hourly_enabled` | `true` | Деплоить `/etc/cron.hourly/logrotate` |

## Поля `logrotate_config`

| Поле | Обязательно | Описание |
|------|-------------|----------|
| `name` | да | Имя файла в `/etc/logrotate.d/` |
| `path` | да | Путь к лог-файлу (glob поддерживается) |
| `rotate` | нет (7) | Количество ротаций |
| `frequency` | нет (daily) | `daily` / `weekly` / `monthly` |
| `compress` | нет (true) | Сжимать старые логи |
| `delaycompress` | нет (true) | Сжимать со сдвигом на 1 ротацию |
| `missingok` | нет (true) | Не падать если файл отсутствует |
| `notifempty` | нет (true) | Пропускать пустые файлы |
| `sharedscripts` | нет (false) | Один postrotate на все файлы |
| `create` | нет | `"mode owner group"` для нового файла |
| `postrotate` | нет | Команда после ротации |

## Пример

```yaml
logrotate_config:
  - name: myapp
    path: /var/log/myapp/*.log
    rotate: 14
    frequency: daily
    create: "0640 root adm"
    postrotate: "systemctl reload myapp"
```
