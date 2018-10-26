#!/bin/bash

echo "provision_idm_1.sh"
source /vagrant/secure.env

# install ipa server and dns server
yum -y install ipa-server bind bind-dyndb-ldap ipa-server-dns

# enable, start and configure firewalld
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --add-service=kerberos \
  --add-service=freeipa-ldap \
  --add-service=freeipa-ldaps \
  --add-service=http \
  --add-service=https \
  --add-service=dns \
  --add-service=ntp \
  --permanent
firewall-cmd --reload

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

  # pick a random one to disable
  if [[ $(($RANDOM % 4)) -eq 0 ]]; then
    ipa user-disable ${FU_USERNAME}
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
ipa sudocmdgroup-add-member --sudocmds="/bin/journalctl *" "log inspection"
ipa sudocmdgroup-add-member --sudocmds="/bin/cat /var/log/audit/audit.log" "log inspection"
ipa sudocmdgroup-add-member --sudocmds="/bin/cat /var/log/messages" "log inspection"
ipa sudocmdgroup-add-member --sudocmds="/bin/cat /var/log/secure" "log inspection"

ipa sudorule-add-allow-command \
  --sudocmdgroups="log inspection" \
  editors

# disable the allow all host based access control rule
ipa hbacrule-disable allow_all

# create a new allow admins host based access control rule
ipa hbacrule-add allow_admins --desc="Allow admins access to all services on all systems"
ipa hbacrule-add-user allow_admins --groups=admins
ipa hbacrule-mod allow_admins --hostcat=all --servicecat=all

# create a new allow trust admins host based access control rule
ipa hbacrule-add allow_trust_admins --desc="Allow trust admins access to all services on all systems"
ipa hbacrule-add-user allow_trust_admins --groups="trust admins"
ipa hbacrule-mod allow_trust_admins --hostcat=all --servicecat=all

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

# create some selinux mappings for admins
ipa selinuxusermap-add "admins" --hostcat=all --desc "This maps administrators to the unconfined_u context" --selinuxuser='unconfined_u:s0-s0:c0.c1023'
ipa selinuxusermap-add-user "admins" --groups="admins"

# create some selinux mappings for trust admins
ipa selinuxusermap-add "trust admins" --hostcat=all --desc "This maps trust admins to the staff_u context" --selinuxuser='staff_u:s0-s0:c0.c1023'
ipa selinuxusermap-add-user "trust admins" --groups="trust admins"

# create some selinux mappings for editors
ipa selinuxusermap-add "editors" --hostcat=all --desc "This maps editors to the user_u context" --selinuxuser='user_u:s0'
ipa selinuxusermap-add-user "editors" --groups="editors"

# create some selinux mappings for ipausers
ipa selinuxusermap-add "ipausers" --hostcat=all --desc "This maps ipausers to the guest_u context" --selinuxuser='guest_u:s0'
ipa selinuxusermap-add-user "ipausers" --groups="ipausers"

# create some interesting password policies for admins
ipa pwpolicy-add "admins" --priority=10 --maxlife=14 --minlife=8 --history=12 --minclasses=3 --minlength=16 --maxfail=2 --failinterval=180 --lockouttime=600

# create some interesting password policies for trust admins
ipa pwpolicy-add "trust admins" --priority=20 --maxlife=28 --minlife=4 --history=12 --minclasses=2 --minlength=12 --maxfail=3 --failinterval=60 --lockouttime=300

# create some interesting password policies for editors
ipa pwpolicy-add "editors" --priority=30 --maxlife=42 --minlife=4 --history=12 --minclasses=2 --minlength=12 --maxfail=3 --failinterval=60 --lockouttime=300

# create some interesting password policies for ipausers
ipa pwpolicy-add "ipausers" --priority=40 --maxlife=91 --minlife=4 --history=12 --minclasses=3 --minlength=8 --maxfail=3 --failinterval=60 --lockouttime=300

# configure our automounts
ipa-client-automount --unattended

# configure nfs to start at boot
systemctl enable nfs-client.target

# start nfs services
systemctl start nfs-client.target

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
echo "${IP_IDM_1}  idm-1.${DOMAIN} idm-1" >> /etc/hosts

exit 0
