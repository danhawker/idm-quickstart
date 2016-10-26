#!/bin/bash

echo "provision_client6_1.sh"
source /vagrant/secure.env

# Use our new IPA based dns server -- will prob be reset at reboot
echo search ${DOMAIN} > /etc/resolv.conf
echo nameserver ${IP_IDM_1} >> /etc/resolv.conf
echo nameserver ${IP_IDM_2} >> /etc/resolv.conf
echo options timeout:1 attempts:2 >> /etc/resolv.conf

# setup our network so it works over reboots
echo '## use the following nameservers in /etc/resolv.conf ##' >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo 'PEERDNS=no' >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DNS1=${IP_IDM_1}" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DNS2=${IP_IDM_2}" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DOMAIN=\"${DOMAIN}\"" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# clean up our /etc/hosts
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "${IP_CLIENT6_1}  client6-1.${DOMAIN} client6-1" >> /etc/hosts

# install our ipa client
yum -y install ipa-client ipa-admintools

ipa-client-install \
  --unattended \
  --enable-dns-updates \
  --principal=admin@${REALM} \
  --password=${ADMIN_PASSWORD} \
  --mkhomedir

# configure our automounts
ipa-client-automount --unattended

echo ${ADMIN_PASSWORD} | kinit admin@${REALM}

# redhat 6.1 needs a service for nfs
ipa service-add --force nfs/client6-1.${DOMAIN}@${REALM}

# get the updated keytab that includes nfs principal
ipa-getkeytab -s idm-1.${DOMAIN} \
  -p host/client6-1.${DOMAIN}@${REALM} \
  -p nfs/client6-1.${DOMAIN}@${REALM} \
  -k /etc/krb5.keytab

# enable our nfs services
chkconfig nfs on
chkconfig nfslock on
chkconfig rpcbind on
chkconfig rpcgssd on
chkconfig rpcidmapd on
chkconfig rpcsvcgssd on

# start the nfs services
service nfs start
service nfslock start
service rpcbind start
service rpcgssd start
service rpcidmapd start
service rpcsvcgssd start

# sanity check dns
for i in _ldap._tcp _kerberos._tcp _kerberos._udp _kerberos-master._tcp _kerberos-master._udp _ntp._udp; do
  echo ""
  dig ${i}.${DOMAIN} srv +nocmd +noquestion +nocomments +nostats +noaa +noadditional +noauthority
done | egrep -v "^;" | egrep _

exit 0
