#!/bin/bash

echo "provision_client6_1.sh"
source /vagrant/secure.env

# Use our new IPA based dns server -- will prob be reset at reboot
echo search ${DOMAIN} > /etc/resolv.conf
echo nameserver ${IP_IDM_1} >> /etc/resolv.conf
echo nameserver ${IP_IDM_2} >> /etc/resolv.conf
echo options timeout:1 attempts:2 >> /etc/resolv.conf

yum -y install ipa-client

ipa-client-install \
  --unattended \
  --enable-dns-updates \
  --principal=admin@${REALM} \
  --password=${ADMIN_PASSWORD} \
  --mkhomedir

ipa-client-automount --unattended

echo ${ADMIN_PASSWORD} | kinit admin@${REALM}

# get an updated keytab that includes nfs principal
ipa-getkeytab -s idm-1.${DOMAIN} \
  -p host/client6-1.${DOMAIN}@${REALM} \
  -p nfs/client6-1.${DOMAIN}@${REALM} \
  -k /etc/krb5.keytab

for i in _ldap._tcp _kerberos._tcp _kerberos._udp _kerberos-master._tcp _kerberos-master._udp _ntp._udp; do
  echo ""
  dig ${i}.${DOMAIN} srv +nocmd +noquestion +nocomments +nostats +noaa +noadditional +noauthority
done | egrep -v "^;" | egrep _

id superman
id batman
id twoface
id cyclops
id flash
id riddler

exit 0
