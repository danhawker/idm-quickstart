#!/bin/bash

echo "provision_idm_1.sh"
source /vagrant/secure.env

# install ipa server and dns server
yum -y install ipa-server bind bind-dyndb-ldap

unset DNS_FORWARDER IPA_FORWARDERS
for DNS_FORWARDER in ${DNS_FORWARDERS}; do
  IPA_FORWARDERS="${IPA_FORWARDERS} --forwarder=${DNS_FORWARDER}"
done

ipa-server-install \
  --unattended \
  --ip-address=${IP_IDM_1} \
  --realm=${REALM} \
  --domain=${DOMAIN} \
  --ds-password="${DM_PASSWORD}" \
  --master-password="${MASTER_PASSWORD}" \
  --admin-password="${ADMIN_PASSWORD}" \
  --mkhomedir \
  --setup-dns \
  --reverse-zone=${DNS_REVERSE_ZONE} \
  ${IPA_FORWARDERS}

# sanity check dns
for i in _ldap._tcp _kerberos._tcp _kerberos._udp _kerberos-master._tcp _kerberos-master._udp _ntp._udp; do
  echo ""
  dig @${IP_IDM_1} ${i}.${DOMAIN} srv +nocmd +noquestion +nocomments +nostats +noaa +noadditional +noauthority
done | egrep -v "^;" | egrep _

echo ${ADMIN_PASSWORD} | kinit admin@${REALM}

# add this server to the idm dns record
ipa dnsrecord-add ${DOMAIN} idm --a-ip-address=${IP_IDM_1}
ipa dnsrecord-add ${DOMAIN} ipa --a-ip-address=${IP_IDM_1}

# sync ptr records on dns updates (does not do gui/cli add, removes or updates)
ipa dnsconfig-mod --allow-sync-ptr=true

# create our hostgroups and automember rules for idm servers
ipa hostgroup-add idm-servers --desc="Hosts that are IDM servers"
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
ipa config-mod --homedirectory=/export/home
ipa config-mod --defaultshell=/bin/bash
ipa config-mod --ipaselinuxusermapdefault=guest_u:s0
ipa config-mod --user-auth-type=password --user-auth-type=otp

# make ipausers a posix group so accounts just work
ipa group-mod --posix ipausers

# create some autogroups based on the state a user lives in
O_IFS=${IFS}
IFS=$'\n'
COUNT=0
for STATE_LINE in $(tail -n 50 /vagrant/states.csv); do
  G_NAME=$(echo ${STATE_LINE} | cut -d , -f 1)
  G_DESC=$(echo ${STATE_LINE} | cut -d , -f 2)
  G_PATTERN=$(echo ${STATE_LINE} | cut -d , -f 3)
  ipa group-add --desc="People who live in ${G_DESC}" ${G_NAME}
  ipa automember-add --type=group --desc="Identify users who live in the state of ${G_DESC}" ${G_NAME}
  ipa automember-add-condition --type=group --key=st --desc="Match users based on the st field" --inclusive-regex="${G_PATTERN}" ${G_NAME}
done
IFS=$O_IFS

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
ipa otptoken-add --desc="Soft Token for aquagirl" --owner=aquagirl --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for armor" --owner=armor --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for batman" --owner=batman --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for beast" --owner=beast --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for spiderman" --owner=spiderman --type=totp --algo=sha512 --digits=6
ipa otptoken-add --desc="Soft Token for superman" --owner=superman --type=totp --algo=sha512 --digits=6

# these users have an OTP
ipa group-add-member admins --users=aquagirl
ipa group-add-member admins --users=armor
ipa group-add-member admins --users=batman
ipa group-add-member admins --users=beast
ipa group-add-member admins --users=spiderman
ipa group-add-member admins --users=superman

id aquagirl
id armor
id batman
id beast
id spiderman
id superman

# these users do not
ipa group-add-member editors --users=argent
ipa group-add-member editors --users=atlas
ipa group-add-member editors --users=daredevil
ipa group-add-member editors --users=flash
ipa group-add-member editors --users=greenlantern
ipa group-add-member editors --users=wondergirl

id argent
id atlas
id daredevil
id flash
id greenlantern
id wondergirl

# let's get CRAY CRAY and create 50,000 users from our fake users file...
O_IFS=${IFS}
IFS=$'\n'

for FAKE_USER_LINE in $(tail -n ${MAX_FAKE_USERS} /vagrant/fake-users.csv); do
  unset FU_USERNAME FU_PASSWORD FU_TITLE FU_FIRSTNAME FU_LASTNAME FU_TELEPHONE FU_ADDRESS_STREET FU_ADDRESS_CITY FU_ADDRESS_STATE FU_ADDRESS_ZIPCODE FU_EMPLOYEE_NUMBER
  FAKE_USER_LINE=$(echo ${FAKE_USER_LINE} | sed -e 's/\"//g')

  #Username,Password,Title,GivenName,Surname,TelephoneNumber,StreetAddress,City,State,ZipCode,EmployeeNumber
  FU_USERNAME=$(echo ${FAKE_USER_LINE} | cut -d , -f 1 | tr [A-Z] [a-z])
  FU_PASSWORD=$(echo ${FAKE_USER_LINE} | cut -d , -f 2)
  FU_TITLE=$(echo ${FAKE_USER_LINE} | cut -d , -f 3)
  FU_FIRSTNAME=$(echo ${FAKE_USER_LINE} | cut -d , -f 4)
  FU_LASTNAME=$(echo ${FAKE_USER_LINE} | cut -d , -f 5)
  FU_TELEPHONE=$(echo ${FAKE_USER_LINE} | cut -d , -f 6)
  FU_ADDRESS_STREET=$(echo ${FAKE_USER_LINE} | cut -d , -f 7)
  FU_ADDRESS_CITY=$(echo ${FAKE_USER_LINE} | cut -d , -f 8)
  FU_ADDRESS_STATE=$(echo ${FAKE_USER_LINE} | cut -d , -f 9)
  FU_ADDRESS_ZIPCODE=$(echo ${FAKE_USER_LINE} | cut -d , -f 10)
  FU_EMPLOYEE_NUMBER=$(echo ${FAKE_USER_LINE} | cut -d , -f 11)

  ipa user-add \
    --title="${FU_TITLE}" \
    --first="${FU_FIRSTNAME}" \
    --last="${FU_LASTNAME}" \
    --employeenumber="${FU_EMPLOYEE_NUMBER}" \
    --phone="${FU_TELEPHONE}" \
    --street="${FU_ADDRESS_STREET}" \
    --city="${FU_ADDRESS_CITY}" \
    --state="${FU_ADDRESS_STATE}" \
    --postalcode="${FU_ADDRESS_ZIPCODE}" \
    "${FU_USERNAME}"
  echo "${FU_PASSWORD}\n${FU_PASSWORD}" | ipa passwd "${FU_USERNAME}"

  # pick a random one to disable
  if [[ $(($RANDOM % 4)) -eq 0 ]]; then
    ipa user-disable ${FU_USERNAME}
  fi

  # pick a random one to make a admin
  if [[ $(($RANDOM % 4)) -eq 1 ]]; then
    ipa group-add-member admins --users=${FU_USERNAME}
  fi

  # pick a random one to make an editor
  if [[ $(($RANDOM % 4)) -eq 2 ]]; then
    ipa group-add-member editors --users=${FU_USERNAME}
  fi

  # pick a random one to give an OTP
  if [[ $(($RANDOM % 4)) -eq 3 ]]; then
    ipa otptoken-add --desc="Soft Token for ${FU_USERNAME}" --owner=${FU_USERNAME} --type=totp --algo=sha512 --digits=6
  fi
done
IFS=${O_IFS}

# add a rule that allows admins GOD access
ipa sudorule-add \
  --desc="This rule allows admins the ability to run ANY command on ALL hosts as ANY user" \
  --cmdcat=all \
  --hostcat=all \
  --runasusercat=all \
  --runasgroupcat=all \
  --order=1 \
  admins
ipa sudorule-add-user --groups=admins admins

# Add rules for editors to do service administration
ipa sudocmdgroup-add --desc="These commands allow a user to control system services." "service administration"
ipa sudocmd-add --desc="This command represents the chkconfig command to manage services." "/sbin/chkconfig *"
ipa sudocmd-add --desc="This command represents the service command to control services." "/sbin/service *"
ipa sudocmd-add --desc="This command represents the systemd command to control services." "/bin/systemctl *"
ipa sudocmdgroup-add-member --sudocmds="/bin/systemctl *" "service administration"
ipa sudocmdgroup-add-member --sudocmds="/sbin/chkconfig *" "service administration"
ipa sudocmdgroup-add-member --sudocmds="/sbin/service *" "service administration"
ipa sudorule-add \
  --desc="This rule allows editors the ability to manage services on ALL hosts as the root user" \
  --hostcat=all \
  --order=2 \
  editors
ipa sudorule-add-runasuser \
  --users=root \
  editors
ipa sudorule-add-allow-command \
  --sudocmdgroups="service administration" \
  editors

# Add rules for editors to do log inspection
ipa sudocmdgroup-add --desc="These commands allow a user to view logs." "log inspection"
ipa sudocmd-add --desc="This command gives access to the systemd control command to review service and system logs." "/bin/journalctl *"
ipa sudocmd-add --desc="This command gives access to view the /var/log/audit/audit.log log files." "/bin/cat /var/log/audit/audit.log"
ipa sudocmd-add --desc="This command gives access to view the /var/log/messages log file." "/bin/cat /var/log/messages"
ipa sudocmd-add --desc="This command gives access to view the /var/log/secure log file." "/bin/cat /var/log/secure"
ipa sudorule-add-allow-command \
  --sudocmdgroups="log inspection" \
  editors

# disable the allow all host based access control rule
ipa hbacrule-disable allow_all

# create a new allow admins host based access control rule
ipa hbacrule-add allow_admins --desc="Allow admins access to all services on all systems"
ipa hbacrule-add-user allow_admins --groups=admins
ipa hbacrule-mod allow_admins --hostcat=all --servicecat=all

# create a new allow editors host based access control rule
ipa hbacrule-add allow_editors --desc="Allow editors access to all services on all systems"
ipa hbacrule-add-user allow_editors --groups=editors
ipa hbacrule-mod allow_editors --hostcat=all --servicecat=all

# create a new allow ipausers host based access control rule
ipa hbacrule-add allow_ipausers --desc="Allow ipausers access to ssh on client systems"
ipa hbacrule-add-user allow_ipausers --groups=ipausers
ipa hbacrule-add-host allow_ipausers --hostgroups=idm-clients
ipa hbacrule-add-service allow_ipausers --hbacsvcs=sshd

# create our automounts
ipa automountmap-add default auto.home
ipa automountkey-add default auto.home --key="*" --info="-sec=krb5p,rw,soft nfs.${DOMAIN}:/export/home/&"
ipa automountkey-add default auto.master --key="/export/home" --info="auto.home"

# configure our automounts
ipa-client-automount --unattended

# configure nfs to start at boot
systemctl enable nfs-client.target

# start nfs services
systemctl start nfs-client.target

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
echo "${IP_IDM_1}  idm-1.${DOMAIN} idm-1" >> /etc/hosts

# prepare our replica
ipa-replica-prepare \
  idm-2.${DOMAIN} \
  --no-wait-for-dns \
  --password=${DM_PASSWORD} \
  --reverse-zone=${DNS_REVERSE_ZONE} \
  --ip-address=${IP_IDM_2}

# copy the replicate info to the parent so we can install it in idm-2
cp /var/lib/ipa/replica-info-idm-2.${DOMAIN}.gpg /vagrant

exit 0
