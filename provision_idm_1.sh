#!/bin/bash

echo "provision_idm_1.sh"
source /vagrant/secure.env

yum -y install ipa-server bind bind-dyndb-ldap

ipa-server-install \
  --unattended \
  --ip-address=${IP_IDM_1} \
  --realm ${REALM} \
  --domain=${DOMAIN} \
  --ds-password="${DM_PASSWORD}" \
  --master-password="${MASTER_PASSWORD}" \
  --admin-password="${ADMIN_PASSWORD}" \
  --mkhomedir \
  --setup-dns \
  --reverse-zone=${DNS_REVERSE_ZONE} \
  --forwarder=${DNS_FORWARDER}

ipa-replica-prepare \
  idm-2.${DOMAIN} \
  --no-wait-for-dns \
  --password=${DM_PASSWORD} \
  --reverse-zone=${DNS_REVERSE_ZONE} \
  --ip-address=${IP_IDM_2}

cp /var/lib/ipa/replica-info-idm-2.${DOMAIN}.gpg /vagrant

for i in _ldap._tcp _kerberos._tcp _kerberos._udp _kerberos-master._tcp _kerberos-master._udp _ntp._udp; do
  echo ""
  dig @${IP_IDM_1} ${i}.${DOMAIN} srv +nocmd +noquestion +nocomments +nostats +noaa +noadditional +noauthority
done | egrep -v "^;" | egrep _

echo ${ADMIN_PASSWORD} | kinit admin@${REALM}

# add this server to the idm dns record
ipa dnsrecord-add ${DOMAIN} idm --a-ip-address=${IP_IDM_1}

# sync ptr records on dns updates (does not do gui/cli add, removes or updates)
ipa dnsconfig-mod --allow-sync-ptr=true

# create our hostgroups and automember rules for idm servers
ipa hostgroup-add idm-servers --desc="Hosts tht are IDM servers"
ipa automember-add idm-servers --type=hostgroup --desc="Match systems that are IDM servers"
ipa automember-add-condition idm-servers --type=hostgroup --inclusive-regex='^idm-*' --key=cn --desc="Match IDM servers based on hostname"
ipa automember-rebuild --type=hostgroup --hosts=idm-1.${DOMAIN}

# create our hostgroups and automember rules for idm clients
ipa hostgroup-add idm-clients --desc="Hosts that are IDM clients"
ipa automember-add idm-clients --type=hostgroup --desc="Match systems that are IDM clients"
ipa automember-add-condition idm-clients --type=hostgroup --inclusive-regex='^.*' --key=cn --desc="Match ALL clients based on any hostname"
ipa automember-add-condition idm-clients --type=hostgroup --exclusive-regex='^idm-*' --key=cn --desc="Exclude clients that are IDM servers based on hostname"

# add this server to the idm-servers host group
ipa hostgroup-add-member --hosts=idm-1.${DOMAIN} idm-servers

# set some sane defaults
ipa config-mod --defaultshell=/bin/bash
ipa config-mod --ipaselinuxusermapdefault=guest_u:s0
ipa config-mod --user-auth-type=password --user-auth-type=otp

# add some users
echo "adding some users, refer to users.txt for information"
ipa user-add --random --first="Clark" --last="Kent" "superman" > /vagrant/users.txt
ipa user-add --random --first="Peter" --last="Parker" "spiderman" >> /vagrant/users.txt
ipa user-add --random --first="Hal" --last="Jordan" "greenlantern" >> /vagrant/users.txt
ipa user-add --random --first="Lorena" --last="Marquez" "aquagirl" >> /vagrant/users.txt
ipa user-add --random --first="Toni" --last="Monetti" "argent" >> /vagrant/users.txt
ipa user-add --random --first="Jack" --last="Keaton" "armor" >> /vagrant/users.txt
ipa user-add --random --first="Jim" --last="Randall" "atlas" >> /vagrant/users.txt
ipa user-add --random --first="William" --last="Burns" "atomicthunderbolt" >> /vagrant/users.txt
ipa user-add --random --first="Catherine" --last="Bell" "badkitty" >> /vagrant/users.txt
ipa user-add --random --first="Sean" --last="Cassidy" "banshee" >> /vagrant/users.txt
ipa user-add --random --first="Barbara" --last="Gordon" "batgirl" >> /vagrant/users.txt
ipa user-add --random --first="Bruce" --last="Wayne" "batman" >> /vagrant/users.txt
ipa user-add --random --first="Kathy" --last="Kane" "batwoman" >> /vagrant/users.txt
ipa user-add --random --first="Hank" --last="McCoy" "beast" >> /vagrant/users.txt
ipa user-add --random --first="Steve" --last="Rogers" "captainamerica" >> /vagrant/users.txt

# Generate some OTP tokens for a few users
ipa otptoken-add --desc="Soft Token for aquagirl" --owner=aquagirl --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for armor" --owner=armor --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for beast" --owner=beast --type=totp --algo=sha512 --digits=6

# these users have an OTP
ipa group-add-member admins --users=aquagirl
ipa group-add-member admins --users=armor
ipa group-add-member admins --users=beast

id aquagirl
id armor
id beast

# these users do not
ipa group-add-member editors --users=greenlantern
ipa group-add-member editors --users=argent
ipa group-add-member editors --users=atlas

id greenlantern
id argent
id atlas

# disable the allow all host based access control rule
ipa hbacrule-disable allow_all

# create a new allow admins host based access control rule
ipa hbacrule-add allow_admins --desc="Allow admins access to all systems"
ipa hbacrule-add-user allow_admins --groups=admins
ipa hbacrule-mod allow_admins --hostcat=all --servicecat=all

# create a new allow editors host based access control rule
ipa hbacrule-add allow_editors --desc="Allow editors access to all client systems"
ipa hbacrule-add-user allow_editors --groups=editors
ipa hbacrule-add-host allow_editors --hostgroups=idm-clients
ipa hbacrule-mod allow_editors --servicecat=all

# Use our new IPA based dns server -- will prob be reset at reboot
echo search ${DOMAIN} > /etc/resolv.conf
echo nameserver ${IP_IDM_1} >> /etc/resolv.conf
echo nameserver ${IP_IDM_2} >> /etc/resolv.conf
echo options timeout:1 attempts:2 >> /etc/resolv.conf

# create an nfs mount for home directories
mkdir -p /home/ipahomes
echo "/home/ipahomes ${IP_CIDR}(rw)" >> /etc/exports

# enable and start nfs-server
systemctl enable nfs-server.service
systemctl start nfs-server.service

# create our automounts
ipa automountkey-add default auto.master --key="/home" --info="auto.home"
ipa automountmap-add default auto.home
ipa automountkey-add default auto.home --key="*" --info="rw,soft idm-1.${DOMAIN}:/home/ipahomes/&"
exit 0
