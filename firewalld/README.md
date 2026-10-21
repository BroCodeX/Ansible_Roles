# Ansible role: firewalld

Настройка firewalld (https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html)

## Role Variables

### Variables for config /etc/firewalld/firewalld.conf
| Variable                           | Default        | Comment |
|------------------------------------|----------------|---------|
| firewalld_enabled                  | true           | Запускать ли роль на хосте |
| firewalld_config_dir               | /etc/firewalld |         |
| firewalld_config_defaultzone       | public         |         |
| firewalld_config_minimalmark       | 100            |         |
| firewalld_config_cleanuponexit     | "yes"          |         |
| firewalld_config_lockdown          | "no"           |         |
| firewalld_config_ipv6_rpfilter     | "yes"          |         |
| firewalld_config_individualcalls   | "no"           |         |
| firewalld_config_logdenied         | "off"          |         |
| firewalld_config_automatichelpers  | system         |         |
| firewalld_config_allowzonedrifting | "yes"          |         |

### Variables for config zones
| Variable                          | Default | Comment                                |
|-----------------------------------|---------|----------------------------------------|
| firewalld_clear_all_zones         | false   | Очистка всех зон от правил             |
| firewalld_additional_zones        | []      | Список дополнительных зон для создания |
| firewalld_configuration           | []      | Список для конфигурации зон            |
| firewalld_configuration_whitelist | []      | Список белых ip адресов                |
| var_files                         | []      | Список файлов с правилами              |

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: ./roles/firewalld
      when: firewalld_enabled
      tags:
        - firewalld
```

## Примеры использования
1. Из-за особенностей работы модуля, при изменении правил для зон в переменной firewalld_configuration, новые правила будут добавляться в firewalld, но старые при этом удаляться не будут. Поэтому необходимо либо сначала явно удалять старое правило, путем добавления к нему state: disabled, либо полностью очищать зону от правил через --extra-vars firewalld_clear_all_zones=true

2. При работе с модулем ansible.posix.firewalld и настройке переменной firewalld_configuration необходимо помнить что параметры icmp_block|icmp_block_inversion|service|port|port_forward|rich_rule|interface|masquerade|source|target являются взаимоисключающими.

3. Если хост входит в несколько групп сразу, то в host_vars ему нужно перечислить в var_files все соответствующие файлы зон. Так же, если хосту нужны какие-то собственные правила, их можно добавить используя firewalld_host_custom_rules:

```yaml
var_files:
  - files/file1.yml
  - files/file2.yml
  - files/file3.yml

firewalld_host_custom_rules: []

firewalld_configuration: "{{ file1_rules + file2_rules + file3_rules + firewalld_host_custom_rules }}"
```

4. Если на определнном хосте **нельзя запускать фаервол** (выключен/не установлен), то для добавления хоста в исключения указываем в `inventory/host_vars/имя_хоста.yml` переменную `firewalld_enabled: false`
  пример:
  ```yaml
      # inventory/host_vars/app26.vimmy.xyz.yml
      firewalld_enabled: false
  ```
