# password_policy

Настраивает политику паролей через `/etc/login.defs` и `pwquality`, выставляет права на системные файлы, делает бэкап.

## Структура

```
tasks/
├── main.yml        — include_vars + import_tasks
├── backup.yml      — бэкап и права на системные файлы
├── login_defs.yml  — lineinfile по password_policy
└── pwquality.yml   — установка libpam-pwquality и деплой конфига
```

---

## Переменные (`defaults/main.yml`)

### Бэкап

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `backup_dir` | `/var/backups/hardening` | Директория бэкапов |
| `system_files` | passwd, shadow, login.defs | Файлы для бэкапа и chmod/chown |

`shadow_group` (`shadow` на Debian, `root` на RedHat) приходит из `vars/`.

### login.defs

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `login_defs_path` | `/etc/login.defs` | Путь к файлу политик |
| `password_policy` | см. defaults | Список `{regexp, line}` для lineinfile |

#### Политика по умолчанию

| Параметр | Значение | Описание |
|----------|----------|----------|
| `UMASK` | 027 | Права на новые файлы |
| `PASS_MAX_DAYS` | 90 | Срок действия пароля |
| `PASS_MIN_DAYS` | 7 | Минимум дней между сменами |
| `PASS_MIN_LEN` | 12 | Минимальная длина |
| `PASS_WARN_AGE` | 30 | Предупреждение до истечения (дней) |
| `SHA_CRYPT_MIN_ROUNDS` | 65536 | Раунды хэширования |

### pwquality

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `pwquality_conf_path` | `/etc/security/pwquality.conf` | Путь к конфигу |
| `pwquality_params` | см. defaults | Список `{name, value}` |

#### Параметры по умолчанию

| Параметр | Значение | Описание |
|----------|----------|----------|
| `minlen` | 12 | Минимальная длина пароля |
| `dcredit` | -1 | Минимум 1 цифра |
| `ucredit` | -1 | Минимум 1 заглавная буква |
| `lcredit` | -1 | Минимум 1 строчная буква |
| `ocredit` | -1 | Минимум 1 спецсимвол |
| `maxrepeat` | 3 | Не более 3 одинаковых символов подряд |

Пакет устанавливается автоматически: `libpam-pwquality` (Debian) / `libpwquality` (RedHat).

---

## Кастомизация

### Добавить файл в бэкап / права

```yaml
system_files:
  - path: /etc/sudoers
    owner: root
    group: root
    mode: '0440'
```

### Изменить политику login.defs

```yaml
password_policy:
  - { regexp: '^PASS_MAX_DAYS', line: 'PASS_MAX_DAYS 60' }
```

### Изменить pwquality

```yaml
pwquality_params:
  - { name: minlen,  value: 16 }
  - { name: minclass, value: 4 }
```
