# network_hardening

Деплоит iptables-правила (персистентно) и применяет sysctl-параметры для hardening сети и ядра.

`iptables` в современных ОС — это `iptables-nft` (`iptables v1.8.x (nf_tables)`), синтаксис классический.

## Структура

```
tasks/
├── main.yml       — import_tasks для iptables и sysctl
├── iptables.yaml  — установка пакетов, rules.v4/rules.v6, сервисы
└── sysctl.yaml    — деплой /etc/sysctl.d/99-hardening.conf
templates/         — rules.v4.j2, rules.v6.j2, 99-hardening.conf.j2
vars/              — Debian.yml, RedHat.yml (пакеты, пути, сервисы)
```

---

## iptables

| ОС | Пакеты | Персистентность | Файлы правил |
|----|--------|-----------------|--------------|
| Debian | `iptables`, `iptables-persistent`, `netfilter-persistent` | `netfilter-persistent` | `/etc/iptables/rules.v4`, `rules.v6` |
| AlmaLinux | `iptables-nft`, `iptables-services` | `iptables.service`, `ip6tables.service` | `/etc/sysconfig/iptables`, `ip6tables` |

> `netfilter-persistent` не поставляется в репозиториях EL (Alma/RHEL), его аналог — `iptables-services`. Формат файлов правил тот же (`iptables-save`).

Конфликтующие сервисы (`nftables`, `firewalld`, `ufw`) останавливаются и отключаются, если присутствуют.

### Переменные

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `iptables_allowed_tcp_ports` | `[22, 80, 443]` | Входящие tcp-порты (ct state NEW) |
| `iptables_docker_enabled` | `false` | Хост крутит Docker: `FORWARD` policy `ACCEPT` в файле (Docker сам выставит свои цепочки), `ip_forward=1`, после reload перезапускается `docker` |

### Правила

**Политика: `INPUT DROP`, `FORWARD DROP`, `OUTPUT ACCEPT`** (IPv4 и IPv6)

| Правило | Действие |
|---------|----------|
| loopback | ACCEPT |
| ESTABLISHED,RELATED | ACCEPT |
| INVALID | DROP |
| XMAS / NULL / FIN-SYN scan | LOG (limit) + DROP |
| tcp dport из `iptables_allowed_tcp_ports`, NEW | ACCEPT |
| ICMP echo-request | ACCEPT |
| ICMPv6 echo + NDP | ACCEPT (только v6) |

Применение идёт через `netfilter-persistent reload` (Debian) / рестарт `iptables`+`ip6tables` (Alma): правила загружаются `iptables-restore` атомарно, но flush затрагивает цепочки Docker — поэтому при `iptables_docker_enabled` docker перезапускается.

```bash
iptables -S                # текущие правила
iptables -L -n -v          # со счётчиками
netfilter-persistent save  # Debian: сохранить ручные изменения
```

---

## sysctl hardening

Деплоит `/etc/sysctl.d/99-hardening.conf` и применяет через `sysctl --system`.

### Переменные

| Переменная | По умолчанию | Описание |
|------------|-------------|----------|
| `sysctl_conf_path` | `/etc/sysctl.d/99-hardening.conf` | Путь к файлу параметров |
| `sysctl_params` | см. defaults | Список `{name, value}` |

### Параметры по умолчанию

| Параметр | Значение | Зачем |
|----------|----------|-------|
| `net.ipv4.conf.all.accept_redirects` | 0 | Запретить ICMP redirect (MITM) |
| `net.ipv4.conf.default.accept_redirects` | 0 | То же для новых интерфейсов |
| `net.ipv4.conf.all.send_redirects` | 0 | Не слать redirect (только роутеры) |
| `net.ipv4.conf.all.log_martians` | 1 | Логировать пакеты с невозможными адресами |
| `net.ipv4.conf.default.log_martians` | 1 | То же для новых интерфейсов |
| `net.ipv4.conf.all.rp_filter` | 1 | Strict reverse path filtering |
| `net.ipv6.conf.all.accept_redirects` | 0 | Запретить ICMPv6 redirect |
| `net.ipv6.conf.default.accept_redirects` | 0 | То же для новых интерфейсов |
| `kernel.yama.ptrace_scope` | 1 | Ограничить ptrace (только родитель→дочерний) |
| `kernel.kptr_restrict` | 2 | Скрыть адреса ядра из /proc |
| `kernel.sysrq` | 0 | Отключить Magic SysRq |
| `net.ipv4.ip_forward` | 0 (1 если `iptables_docker_enabled`) | Форвардинг IPv4 — нужен Docker для NAT/маршрутизации между контейнерами |
| `net.ipv6.conf.all.forwarding` | 0 (1 если `iptables_docker_enabled`) | То же для IPv6 |

### Добавление параметра

```yaml
sysctl_params:
  - { name: 'net.ipv4.tcp_syncookies', value: 1 }
```
