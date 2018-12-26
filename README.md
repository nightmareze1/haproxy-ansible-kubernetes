# haproxy-ansible-kubernetes
This role install HAPROXY,KEEPALIVED,STATS AND HATOP

1- Launch ha-proxy ansible you need update the inventory with you haproxy ips.

- based in openshift and kubespray documentation:

https://blog.openshift.com/haproxy-highly-available-keepalived/

https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ha-mode.md

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

## HAProxy - Frontend and Backends 
In this example I have two kubernetes clusters configured in my haproxy.yml (openshift and k8s-native with kubespray)
```
root@jenkins:/tmp/haproxy-ansible-kubernetes/ansible/inventory/group_vars# cat haproxy/haproxy.yml
```
```
---
haproxy_global_maxconn: 50000
haproxy_global_ulimit: 100042

haproxy_frontends:
  - name: 'openshift_router_http'
    bind: '*:80'
    backends:
      - 'openshift_router80'
  - name: 'openshift_router_ssl'
    bind: '*:443'
    backends:
      - 'openshift_router443'
  - name: 'openshift_router_mgmt'
    bind: '*:8443'
    backends:
      - 'openshift_mgmt8443'
  - name: 'kubernetes_api'
    bind: '*:6443'
    backends:
      - 'kubernetes_api6443'
  - name: 'kubernetes_traefik_http'
    bind: '*:9090'
    backends:
      - 'kubernetes_traefik9090'


haproxy_backends:
  - name: 'openshift_router80'
    balance: 'source'
    mode: 'tcp'
    server:
      - name: 'master0.itshell.local'
        value: '172.16.250.160:80'
        extra: 'check'
      - name: 'master1.itshell.local'
        value: '172.16.250.161:80'
        extra: 'check'
      - name: 'master2.itshell.local'
        value: '172.16.250.162:80'
        extra: 'check'
  - name: 'openshift_router443'
    balance: 'source'
    mode: 'tcp'
    server:
      - name: 'master0.itshell.local'
        value: '172.16.250.160:443'
        extra: 'check'
      - name: 'master1.itshell.local'
        value: '172.16.250.161:443'
        extra: 'check'
      - name: 'master2.itshell.local'
        value: '172.16.250.162:443'
        extra: 'check'
  - name: 'openshift_mgmt8443'
    balance: 'source'
    mode: 'tcp'
    server:
      - name: 'master0.itshell.local'
        value: '172.16.250.160:8443'
        extra: 'check'
      - name: 'master1.itshell.local'
        value: '172.16.250.161:8443'
        extra: 'check'
      - name: 'master2.itshell.local'
        value: '172.16.250.162:8443'
        extra: 'check'
  - name: 'kubernetes_api6443'
    balance: 'source'
    mode: 'tcp'
    server:
      - name: 'kub0'
        value: '172.16.250.180:6443'
        extra: 'check'
      - name: 'kub1'
        value: '172.16.250.181:6443'
        extra: 'check'
      - name: 'kub2'
        value: '172.16.250.182:6443'
        extra: 'check'
  - name: 'kubernetes_traefik9090'
    balance: 'source'
    mode: 'tcp'
    server:
      - name: 'minion0'
        value: '172.16.250.190:80'
        extra: 'check'
      - name: 'minion1'
        value: '172.16.250.191:80'
        extra: 'check'
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

## Check ping VIP IP

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/3.png)

## Check haproxy stats using HATOP ```(inside one haproxy execute)```
```
hatop -s /var/lib/haproxy/stats
```
![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/4.png)

## Check haproxy stats using url 

```http://172.16.250.150:9000/haproxy_stats```

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/5.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/7.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/8.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/9.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/10.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/11.png)

![alt text](https://raw.githubusercontent.com/nightmareze1/haproxy-ansible-kubernetes/master/img/12.png)

# ENJOY




