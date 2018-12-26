# haproxy-ansible-kubernetes
This role install HAPROXY,KEEPALIVED,STATS AND HATOP

1- Launch ha-proxy ansible you need update the inventory with you haproxy ips.

## inventory example
```
root@jenkins:/tmp/haproxy-ansible-kubernetes/ansible# cat inventory/hosts.ini
```

```
[all]
haproxy1 ansible_host=172.16.250.151 ip=172.16.250.151 state=MASTER priority=100
haproxy2 ansible_host=172.16.250.152 ip=172.16.250.152 state=BACKUP priority=98

[haproxy]
haproxy1
haproxy2

[keepalived]
haproxy1
haproxy2
```
## Configure VIP (Loadbalancer IP for k8s) 
```
root@jenkins:/tmp/haproxy-ansible-kubernetes/ansible# ls
inventory  playbook.yml  roles
root@jenkins:/tmp/haproxy-ansible-kubernetes/ansible# cat inventory/group_vars/keepalived/keepalived.yml
```

## VIP - LOADBALANCER IP
```
keepalived_loadbalancer_vip: '172.16.250.150'
```

2- Later, The complete step1 you are ready to launch ansible-playbook.(optional launch common and syslog)
```
---
- name: haproxy provision
  hosts: haproxy
  become: yes
  become_user: 'root'
  become_method: 'sudo'

  roles:
   #  - { role: common, tags: pkg-common }
   #  - { role: rsyslog, tags: rsyslog }
    - { role: haproxy, tags: haproxy } 
    - { role: keepalived, tags: keepalived }
```

```
root@jenkins# sudo ansible-playbook -i inventory/hosts.ini playbook.yml --extra-vars="install=True allow_restart=True" -vvvv
```
![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/1.png)

3- playbook results:

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/2.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/3.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/4.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/5.png)



