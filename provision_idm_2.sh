#!/bin/bash

echo "provision_idm_2.sh"
source /vagrant/secure.env

yum -y install ipa-server bind bind-dyndb-ldap

cp /vagrant/replica-info-idm-2.${DOMAIN}.gpg /var/lib/ipa
rm /vagrant/replica-info-idm-2.${DOMAIN}.gpg

ipa-replica-install \
  --unattended \
  --ip-address=${IP_IDM_2} \
  --setup-ca \
  --setup-dns \
  --password="${DM_PASSWORD}" \
  --admin-password="${ADMIN_PASSWORD}" \
  --mkhomedir \
  --reverse-zone=${DNS_REVERSE_ZONE} \
  --forwarder=${DNS_FORWARDER} \
  /var/lib/ipa/replica-info-idm-2.${DOMAIN}.gpg

for i in _ldap._tcp _kerberos._tcp _kerberos._udp _kerberos-master._tcp _kerberos-master._udp _ntp._udp; do
  echo ""
  dig @${IP_IDM_2} ${i}.${DOMAIN} srv +nocmd +noquestion +nocomments +nostats +noaa +noadditional +noauthority
done | egrep -v "^;" | egrep _

echo ${ADMIN_PASSWORD} | kinit admin@${REALM}

# add this server to the idm dns record
ipa dnsrecord-add ${DOMAIN} idm --a-ip-address=${IP_IDM_2}

# rebuild auto hostgroup membership for this server
ipa automember-rebuild --type=hostgroup --hosts=idm-2.${DOMAIN}

# add some users
ipa user-add --random --first="Brian" --last="Braddock" "captainbritain" >> /vagrant/users.txt
ipa user-add --random --first="Piotr" --last="Nikolaievitch Rasputin" "colossus" >> /vagrant/users.txt
ipa user-add --random --first="Jack" --last="Ryder" "creeper" >> /vagrant/users.txt
ipa user-add --random --first="Matt" --last="Murdock" "daredevil" >> /vagrant/users.txt
ipa user-add --random --first="Scott" --last="Summers" "cyclops" >> /vagrant/users.txt
ipa user-add --random --first="Floyd" --last="Lawton" "deadshot" >> /vagrant/users.txt
ipa user-add --random --first="Oliver" --last="Queen" "greenarrow" >> /vagrant/users.txt
ipa user-add --random --first="Andrea" --last="Thomas" "isis" >> /vagrant/users.txt
ipa user-add --random --first="Reed" --last="Richards" "mrfantastic" >> /vagrant/users.txt
ipa user-add --random --first="Kurt" --last="Wagner" "nightcrawler" >> /vagrant/users.txt
ipa user-add --random --first="Edward" --last="Nygma" "riddler" >> /vagrant/users.txt
ipa user-add --random --first="Anna" --last="Marie" "rogue" >> /vagrant/users.txt
ipa user-add --random --first="Barry" --last="Allen" "flash" >> /vagrant/users.txt
ipa user-add --random --first="Harvey" --last="Dent" "twoface" >> /vagrant/users.txt
ipa user-add --random --first="Donna" --last="Troy" "wondergirl" >> /vagrant/users.txt

# Generate some OTP tokens for a few users
ipa otptoken-add --desc="Soft Token for superman" --owner=superman --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for spiderman" --owner=spiderman --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for batman" --owner=batman --type=totp --algo=sha512 --digits=6

# these users have an OTP
ipa group-add-member admins --users=superman
ipa group-add-member admins --users=spiderman
ipa group-add-member admins --users=batman

id superman
id spiderman
id batman

# these users do not
ipa group-add-member editors --users=daredevil
ipa group-add-member editors --users=flash
ipa group-add-member editors --users=wondergirl

id daredevil
id flash
id wondergirl

# Use our new IPA based dns server -- will prob be reset at reboot
echo search ${DOMAIN} > /etc/resolv.conf
echo nameserver ${IP_IDM_1} >> /etc/resolv.conf
echo nameserver ${IP_IDM_2} >> /etc/resolv.conf
echo options timeout:1 attempts:2 >> /etc/resolv.conf

exit 0
