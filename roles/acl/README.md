Ansible Role: ACL
=================

This role sets POSIX ACLs (`setfacl`) using the `ansible.posix.acl` module.

Role Variables
--------------

Variable | Default | Description
-------- | ------- | -----------
acl_install_package | true | Install the `acl` package
acl_entries | [] | A list of ACL entries

Parameters for `acl_entries[]` | Default | Description
----------------------- | --------------------- | --------
path | Not set | Path
entity | Not set | Username or group name
etype | Not set | `user`/`group`/`mask`/`other`
permissions | Not set | Permissions, e.g., `rwX`
recursive | false | Apply recursively (`-R`)
default | false | Also set default ACLs (`-d`)
state | present | `present`/`absent`/`query`

Example
------

```yaml
acl_entries:
# setfacl -R -m g:bitrix:rwX ... ; setfacl -R -d -m g:bitrix:rwX ...
- path: /home/bitrix/feeds.ekonika.ru/feeds
entity: bitrix
etype: group
permissions: rwX
recursive: true
default: true
```

Role Tags
---------

Tag | Description
--- | -----------
acl | All tasks in the role
