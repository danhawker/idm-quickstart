# Installation of Red Hat Identity Management

<!-- MarkdownTOC depth=4 autolink=true bracket=round -->

- [Install Base Operating Systems](#install-base-operating-systems)
- [Install Red Hat Identity Management Server Software](#install-red-hat-identity-management-server-software)
- [Configure Red Hat Identity Management Servers](#configure-red-hat-identity-management-servers)
- [Verification](#verification)
  - [Explore the Web GUI](#explore-the-web-gui)
- [Initial Configuration](#initial-configuration)

<!-- /MarkdownTOC -->

# Install Base Operating Systems
Let's go ahead and install our Base OSes for all our systems.  This will speed
things up later on because we will assume that all systems are installed, just
not configured.

* idm-1.example.test - RHEL 7
* idm-2.example.test - RHEL 7
* client7-1.example.test - RHEL 7
* client6-1.example.test - RHEL 7

For all of our systems, let's make sure they are fully updated:
```
yum -y upgrade
```

# Install Red Hat Identity Management Server Software
We need to install the IDM software on the following systems:

* idm-1.example.test
* idm-2.example.test

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

Save the generated passwords:
```
echo DM_PASSWORD=\"${DM_PASSWORD}\" > secure.env
echo MASTER_PASSWORD=\"${MASTER_PASSWORD}\" >> secure.env
echo ADMIN_PASSWORD=\"${ADMIN_PASSWORD}\" >> secure.env
```

# Configure Red Hat Identity Management Servers
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
  --forwarder=8.8.8.8 --forwarder=8.8.4.4
```

You may need to adjust firewall settings to allow inbound traffic.

# Verification
You'll need to ensure that the proper (and correct) DNS entries exist.  You can
run the following:

```
for i in _ldap._tcp _kerberos._tcp _kerberos._udp _kerberos-master._tcp _kerberos-master._udp _ntp._udp; do
  echo ""
  dig @172.17.0.2 ${i}.example.test srv +nocmd +noquestion +nocomments +nostats +noaa +noadditional +noauthority
done | egrep -v "^;" | egrep _
```

The output should look like:
```
_ldap._tcp.example.test. 86400  IN  SRV 0 100 389 idm-1.example.test.
_kerberos._tcp.example.test. 86400 IN SRV 0 100 88 idm-1.example.test.
_kerberos._udp.example.test. 86400 IN SRV 0 100 88 idm-1.example.test.
_kerberos-master._tcp.example.test. 86400 IN SRV 0 100 88 idm-1.example.test.
_kerberos-master._udp.example.test. 86400 IN SRV 0 100 88 idm-1.example.test.
_ntp._udp.example.test. 86400 IN  SRV 0 100 123 idm-1.example.test.
```

Those SRV records allow clients (provided they have DNS properly configured) to
automagically configure themselves for authentication.

## Explore the Web GUI
Once completed, you should go to the Web GUI and browse around.  Doing so will
require proper DNS resolution or a properly configured ```/etc/hosts``` on the
client as you will be redirected to the FQDN of the IDM server.

[https://idm-1.example.test](https://idm-1.example.test) or [https://172.17.0.2](https://172.17.0.2)

Username: ```admin```

Password: ```${ADMIN_PASSWORD}```

# Initial Configuration

