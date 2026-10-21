Role Name
=========
При наличии блокировки доступа к репозиториям эластика на таргет хосте необходимо:
- использовать http прокси при запуске плейбука
- развернуть elastic package registry на одном из хостов, указать его url в конфиге кибаны

*Сертификаты генерируются на одной из нод, синк на остальные на текущий момент в плейбуке не описан, **необходимо принести вручную***

*Начиная с 8 версии для работы APM сервера требуется интеграция через Fleet, которому необходим включенный xpack.security*

*При работе в production mode (указании network.host) также требуется включенный xpack.security.transport.ssl*

Опционально можно добавить nginx проксирование перед кибаной (kibana_nginx_proxy_exist = true)


### Установка:

1. Добавить в инвентори группу с хостами эластика, указать имя группы в переменной **elasticsearch_inventory_hosts** 

2. Проверить/переопределить значения переменных в group_vars. Обратить внимание на:
- elasticsearch_heap_size
- kibana_domain_name
- сетевые адреса для биндинга - по умолчанию elasticsearch_network_host содержит IP из инвентори и локалхост (на который настроен коннект кибаны, экспортера, apm сервера)
- пароли

3. Экспортировать пароли* и http прокси url:
```sh
# * в данном случае пароли не экспортировать, а указать в group_vars

# export ES_BOOTSTRAP_PASSWORD="some_password"
# export ES_KEYSTORE_PASSWORD="some_password"
# export ES_ELASTIC_PASSWORD="some_password"
# export ES_KIBANA_PASSWORD="some_password"
# export ES_APM_PASSWORD="some_password"
# export KIBANA_ENCRYPTION_KEY="some_password"


export HTTP_PROXY="http://login:pass@IP:port"
export HTTPS_PROXY="http://login:pass@IP:port"
```
4. Выполнить установку стека, поставить экспортер, кибану, apm-server, развернуть elastic package registry. Примеры:
```sh
# запуск всех задач:
ansible-playbook -i inventory/dev/hosts.yaml elk-dev.yml -D

# только конфигурация (рестарт в случае наличия изменений):
ansible-playbook -i inventory/dev/hosts.yaml elk-dev.yml -t config_elastic -D

# установка/смена паролей системных пользователей (elastic, kibana_sytem, apm_system и др.):
ansible-playbook -i inventory/dev/hosts.yaml elk-dev.yml -t users_elastic -D

# например только установка экспортера, кибаны, apm-server'а (при необходимости):
ansible-playbook -i inventory/dev/hosts.yaml elk-dev.yml -t elastic_exporter,kibana,apm_server -D

# развернуть отдельно elastic package registry (при необходимости в установке apm-server'а)
# необходимо наличие http прокси в env (export HTTP_PROXY="") и переменных apm_server_install=true , epr_proxy_enable=true
ansible-playbook -i inventory/dev/hosts.yaml elk-dev.yml -t docker,epr_proxy -D
```
5. Добавить APM интеграцию в кибане (при установке apm-server'а)
Перейти по url http://${KIBANA_URL}/app/fleet/integrations/apm/add-integration
- в разделе 'Server configuration' указать хост и url из
```sh
grep 'host:' /etc/apm-server/apm-server.yml
```
- в разделе Agent authorization настроить авторизацию агентов (или оставить по дефолту)
- поменять имя политики на APM ${host} ...
- Save and continue

Интеграцию с остальными apm серверами добавить по аналогии

Requirements
------------

- версия elasticsearch >= 7

- debian-based дистрибутивы


Role Variables
--------------



Dependencies
------------

- docker для развертывания elastic package registry
- опционально nginx для проксирования кибаны (kibana_nginx_proxy_exist = true)

Example Playbook
----------------
```yaml
- hosts: elastic-stage
  become: yes
  roles:
    # ansible-galaxy install geerlingguy.docker
    - role: geerlingguy.docker
      tags: docker
      when:
        - apm_server_install
        - epr_proxy_enabled

    - role: elastic_stack
      tags: elastic_stack

  environment:
    http_proxy: "{{ lookup('env', 'HTTP_PROXY') }}"
    https_proxy: "{{ lookup('env', 'HTTPS_PROXY') }}"
```
