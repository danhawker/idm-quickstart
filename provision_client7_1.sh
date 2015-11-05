#!/bin/bash

echo "provision_client7_1.sh"
source /vagrant/secure.env

# Use our new IPA based dns server -- will prob be reset at reboot
echo search ${DOMAIN} > /etc/resolv.conf
echo nameserver ${IP_IDM_1} >> /etc/resolv.conf
echo nameserver ${IP_IDM_2} >> /etc/resolv.conf
echo options timeout:1 attempts:2 >> /etc/resolv.conf

# setup our network so it works over reboots
nmcli conn modify enp0s3 ipv4.ignore-auto-dns yes
nmcli conn modify enp0s3 ipv4.dns "${IP_IDM_1} ${IP_IDM_2}"
nmcli conn modify enp0s3 ipv4.dns-search "${DOMAIN}"
nmcli conn show enp0s3

# clean up our /etc/hosts
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "${IP_CLIENT7_1}  client7-1.${DOMAIN} client7-1" >> /etc/hosts

# install our ipa client
yum -y install ipa-client

ipa-client-install \
  --unattended \
  --enable-dns-updates \
  --principal=admin@${REALM} \
  --password=${ADMIN_PASSWORD} \
  --mkhomedir

# configure our automounts
ipa-client-automount --unattended

# configure nfs to start at boot
systemctl enable nfs-client.target

# start nfs services
systemctl start nfs-client.target

# sanity check dns
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
