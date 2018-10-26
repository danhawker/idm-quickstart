#!/bin/bash

echo "provision_nfs.sh"
source /vagrant/secure.env

# Use our new IPA based dns server -- will prob be reset at reboot
echo search ${DOMAIN} > /etc/resolv.conf
echo nameserver ${IP_IDM_1} >> /etc/resolv.conf
echo options timeout:1 attempts:2 >> /etc/resolv.conf

# setup our network so it works over reboots
nmcli conn modify "${NETWORK_DEVICE}" ipv4.ignore-auto-dns yes
nmcli conn modify "${NETWORK_DEVICE}" ipv4.dns "${IP_IDM_1}"
nmcli conn modify "${NETWORK_DEVICE}" ipv4.dns-search "${DOMAIN}"
nmcli conn show "${NETWORK_DEVICE}"

# clean up our /etc/hosts
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "${IP_NFS}  nfs.${DOMAIN} nfs" >> /etc/hosts

# install our ipa client and admin tools
yum -y install ipa-client ipa-admintools

ipa-client-install \
  --unattended \
  --enable-dns-updates \
  --principal=admin@${REALM} \
  --password=${ADMIN_PASSWORD} \
  --mkhomedir

# sanity check dns
for i in _ldap._tcp _kerberos._tcp _kerberos._udp _kerberos-master._tcp _kerberos-master._udp _ntp._udp; do
  echo ""
  dig ${i}.${DOMAIN} srv +nocmd +noquestion +nocomments +nostats +noaa +noadditional +noauthority
done | egrep -v "^;" | egrep _

echo ${ADMIN_PASSWORD} | kinit admin@${REALM}

# redhat 6.1 needs a service for nfs-server
ipa service-add --force nfs/nfs.${DOMAIN}@${REALM}

# get the updated keytab that includes nfs principal
ipa-getkeytab -s idm-1.${DOMAIN} \
  -p host/nfs.${DOMAIN}@${REALM} \
  -p nfs/nfs.${DOMAIN}@${REALM} \
  -k /etc/krb5.keytab

# create an nfs mount for home directories
echo "/export *(rw,subtree_check,fsid=0,sec=krb5:krb5i:krb5p)" >> /etc/exports

# enable, start and configure firewalld
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --add-service=nfs --add-service=nfs3 --add-service=rpc-bind --permanent
firewall-cmd --reload

# enable and start nfs server
systemctl enable nfs-server.service
systemctl start nfs-server.service

# make sure our demo users' home dirs exist
for x in $(ipa user-find | grep 'User login:' | awk '{ print $3; }'); do
  cp -ra /etc/skel /export/home/$x
  chown -R $x: /export/home/$x
done

exit 0
