#!/bin/bash

echo "provision_idm_2.sh"
source /vagrant/secure.env

# install ipa server and dns server
yum -y install ipa-server bind bind-dyndb-ldap

# copy and then remove the replica information
cp /vagrant/replica-info-idm-2.${DOMAIN}.gpg /var/lib/ipa
rm /vagrant/replica-info-idm-2.${DOMAIN}.gpg

unset DNS_FORWARDER IPA_FORWARDERS
for DNS_FORWARDER in ${DNS_FORWARDERS}; do
  IPA_FORWARDERS="${IPA_FORWARDERS} --forwarder=${DNS_FORWARDER}"
done

# install the replica
ipa-replica-install \
  --unattended \
  --ip-address=${IP_IDM_2} \
  --setup-ca \
  --setup-dns \
  --password="${DM_PASSWORD}" \
  --admin-password="${ADMIN_PASSWORD}" \
  --mkhomedir \
  --reverse-zone=${DNS_REVERSE_ZONE} \
  ${IPA_FORWARDERS} \
  /var/lib/ipa/replica-info-idm-2.${DOMAIN}.gpg

# sanity check dns
for i in _ldap._tcp _kerberos._tcp _kerberos._udp _kerberos-master._tcp _kerberos-master._udp _ntp._udp; do
  echo ""
  dig @${IP_IDM_2} ${i}.${DOMAIN} srv +nocmd +noquestion +nocomments +nostats +noaa +noadditional +noauthority
done | egrep -v "^;" | egrep _

# configure our automounts
ipa-client-automount --unattended

echo ${ADMIN_PASSWORD} | kinit admin@${REALM}

# add this server to the idm dns record
ipa dnsrecord-add ${DOMAIN} idm --a-ip-address=${IP_IDM_2}
ipa dnsrecord-add ${DOMAIN} ipa --a-ip-address=${IP_IDM_2}

# rebuild auto hostgroup membership for this server
ipa automember-rebuild --type=hostgroup --hosts=idm-2.${DOMAIN}

# configure nfs to start at boot
systemctl enable nfs.service
systemctl enable nfs-secure.service

# start nfs services
systemctl start nfs.service
systemctl start nfs-secure.service

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
echo "${IP_IDM_2}  idm-2.${DOMAIN} idm-2" >> /etc/hosts

exit 0
