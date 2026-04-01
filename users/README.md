Ansible Role: Users
===================

Роль описывает добавление и удаление пользователей, публичных ключей и прав sudo

При этом:
- пользователи создаются при отсутствии на сервере
- удаляются все публичные ключи ssh, которых нет в переменной pubkeys
- права sudo задаются посредством создания файла в /etc/sudoers.d
- ограничить sudo можно, указав sudo_commands
- при удалении пользователя с сервера по умолчанию **не** удаляется его домашний каталог, но удаляется файл в /etc/sudoers.d

Requirements
------------

Нет


Dependencies
------------

Нет

Role Variables
--------------

Variable | Type | Description
-------- | ---- | -----------
users_users | list | Список словарей с пользователями

Параметры users_users[] | Значение по умолчанию | Описание
----------------------- | --------------------- | --------
pubkeys | не задано | Список публичных ключей ssh
remove_homedir | false | Удалять ли домашний каталог пользователя, актуально для `state=absent`
shell | /bin/bash | Оболочка пользователя
state | present | Состояние для пользователя, `present`/`absent`
sudo | false | Добавлять ли пользователя в sudoers
sudo_commands | ALL | Пути к командам для sudo, одна команда указывается строкой, несколько команд указываются списком
username | не задано | Имя пользователя

Пример переменной `users_users`
-------------------------------

```yaml
users_users:
  # добавить пользователя с одним публичным ключом
  - username: user1
    pubkeys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMzoilq9OLR7LJG/EaPNfn6l21S/MBlCbTiVFFC38Xs user1
  # добавить пользователя с полными правами sudo и одним публичным ключом
  - username: user2
    sudo: true
    pubkeys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl83QyipVEbcRgiqgmGQnEkdDPin6ef9YojBOH/sMxT user2
  # добавить пользователя с правами sudo на выполнение команды
  - username: user3
    sudo: true
    sudo_commands: /opt/script.sh
  # добавить пользователя с правами sudo на выполнение нескольких команд и несколькими публичными ключами
  - username: user4
    sudo: true
    sudo_commands:
      - /opt/script.sh
      - /opt/script2.sh
    pubkeys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtfFB40gd4QRzpmwENa1NFP+Up2V1r8gRriJeEC2Kc2 user4
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKs0NRISEYkaQcCidKfa/cdCs0hLmu9VMPnSeiwIhmMm user4-laptop
  # удалить пользователя
  - username: user5
    state: absent
  # удалить пользователя и удалить его домашнюю директорию
  - username: user6
    state: absent
    remove_homedir: true
```

Role Tags
---------

Tag | Description
--- | -----------
users_create | Добавление пользователей
users_remove | Удаление пользователей
