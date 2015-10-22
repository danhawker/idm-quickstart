# Installation of Red Hat Identity Management

## Update Base Operating System
```
yum -y upgrade
```

## Install Red Hat Identity Management on idm-1.example.test
Install the necessary packages:
```
yum -y install ipa-server bind bind-dyndb-ldap
```
Generate (and properly record) some passwords:
```
  export DM_PASSWORD="$(openssl rand -base64 16 | tr -dc [:alnum:])"
  export MASTER_PASSWORD="$(openssl rand -base64 16 | tr -dc [:alnum:])"
  export ADMIN_PASSWORD="$(openssl rand -base64 16 | tr -dc [:alnum:])"
```

Now run the install (which utlizes the passwords above):
```
ipa-server-install \
  --unattended \
  --ip-address=172.17.0.2 \
  --realm=EXAMPLE.TEST \
  --domain=example.test \
  --ds-password="${DM_PASSWORD}" \
  --master-password="${MASTER_PASSWORD}" \
  --admin-password="${ADMIN_PASSWORD}" \
  --mkhomedir \
  --setup-dns \
  --reverse-zone=0.17.172.in-addr.arpa. \
  --forwarder=8.8.8.8
```

## Explore the Web GUI
Once completed, you should go to the Web GUI and browse around.  Doing so will
require proper DNS resolution or a properly configured ```/etc/hosts``` on the
client as you will be redirected to the FQDN of the IDM server.

[https://idm-1.example.test](https://idm-1.example.test) or [https://172.17.0.2](https://172.17.0.2)

Username: ```admin```

Password: ```${ADMIN_PASSWORD}```
