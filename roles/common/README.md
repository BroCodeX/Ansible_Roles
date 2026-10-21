Ansible Role: Common
=========

Роль описывает настройку базовых параметров сервера:
- установка базовых пакетов
- смена таймзоны
- параметры sysctl
- параметры ulimit
- установка цвета для промпта

Requirements
------------

Роль под debian - based дистрибутивы

Role Variables
--------------
| Variable | Description |
| --- | --- |
| upgrade_all | обновить все пакеты |
| base_packages | список пакетов для установки |
| set_timezone| сменить таймзону |
| tz_name | имя таймзоны |
| sysctl_parameters| параметры sysctl |
| set_ulimit | установить лимиты из файла |

Role Tags
----
| Tag | Level | Description |
| --- | --- | --- |
| common | all | общий |
| packages | install | установка пакетов |
| upgrade_all | install | обновить все пакеты |
| tz | tz | установка таймзоны |
| sysctl | sysctl | установка параметров sysctl |
| ulimit | config | установка параметров ulimit |
| iptables | config | применение правил iptables |
| prompt | config | настройки bash профиля |

Dependencies
------------

Нет

Example Playbook
----------------

```yaml
- hosts: "{{ host }}"
  gather_facts: true
  become: true
  roles:
    - common
```
```sh
# выполнение роли на хосте
ansible-playbook -i -i inventory/$env/inventory.yaml common.yml -t 'common'

# установка параметров sysctl
ansible-playbook -i -i inventory/$env/inventory.yaml common.yml -t 'sysctl'

# обновление пакетов (задать upgrade_all=true)
ansible-playbook -i -i inventory/$env/inventory.yaml common.yml -t 'upgrade_all' -e "upgrade_all=true"
```
