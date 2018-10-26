#!/bin/bash

echo "provision.sh"

NETWORK_DEVICE="eth0"

# clean up for Red Hat Enterprise Linux
cat /etc/redhat-release | grep 'Red Hat Enterprise Linux Server' > /dev/null 2>&1 && {
  subscription-manager repos --disable='*'
  subscription-manager repos --enable='rhel-7-server-rpms'
  NETWORK_DEVICE="eth0"
  systemctl disable iptables
  systemctl disable ip6tables
  systemctl stop iptables
  systemctl stop ip6tables
}

# clean up yum
yum -y clean all

# Do an upgrade of packages
yum -y upgrade --exclude=kernel*

# make sure we have the nfs-utils
yum -y install nfs-utils NetworkManager

# make sure NetworkManager is running
systemctl enable NetworkManager
systemctl status NetworkManager || systemctl start NetworkManager

# use a default of example.test if not specified
DOMAIN=${DOMAIN:-example.test}

# specify some IPs for our IPs
IP_CIDR="172.17.0.0/24"
IP_IDM_1="172.17.0.2"
IP_IDM_2="172.17.0.3"
IP_NFS="172.17.0.4"
IP_CLIENT7_1="172.17.0.9"
IP_CLIENT6_1="172.17.0.19"

# set up some dns stuffs
DNS_REVERSE_ZONE="0.17.172.in-addr.arpa."
DNS_FORWARDERS="8.8.8.8 8.8.4.4"

# set a max of fake users (up to 50000)
MAX_FAKE_USERS=100

# make sure all hosts can be found
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "${IP_IDM_1}  idm-1.${DOMAIN} idm-1" >> /etc/hosts
echo "${IP_IDM_2}  idm-2.${DOMAIN} idm-2" >> /etc/hosts
echo "${IP_NFS}  nfs.${DOMAIN} nfs" >> /etc/hosts
echo "${IP_CLIENT7_1}  client7-1.${DOMAIN} client7-1" >> /etc/hosts
echo "${IP_CLIENT6_1}  client6-1.${DOMAIN} client6-1" >> /etc/hosts

# create a new set of passwords to be used for our installation
if [ ! -f /vagrant/secure.env ]; then
  echo "Generating new passwords for use with our setup..."
  echo DOMAIN=\"${DOMAIN}\" >> /vagrant/secure.env
  echo REALM=\"$(echo ${DOMAIN} | tr [a-z] [A-Z])\" >> /vagrant/secure.env
  echo NETWORK_DEVICE=\"${NETWORK_DEVICE}\" >> /vagrant/secure.env
  echo IP_CIDR=\"${IP_CIDR}\" >> /vagrant/secure.env
  echo IP_IDM_1=\""${IP_IDM_1}"\" >> /vagrant/secure.env
  echo IP_IDM_2=\""${IP_IDM_2}"\" >> /vagrant/secure.env
  echo IP_NFS=\""${IP_NFS}"\" >> /vagrant/secure.env
  echo IP_CLIENT7_1=\""${IP_CLIENT7_1}"\" >> /vagrant/secure.env
  echo IP_CLIENT6_1=\""${IP_CLIENT6_1}"\" >> /vagrant/secure.env
  echo DNS_REVERSE_ZONE=\""${DNS_REVERSE_ZONE}"\" >> /vagrant/secure.env
  echo DNS_FORWARDERS=\""${DNS_FORWARDERS}"\" >> /vagrant/secure.env
  echo DM_PASSWORD=\""$(openssl rand -base64 16 | tr -dc [:alnum:])"\" >> /vagrant/secure.env
  echo ADMIN_PASSWORD=\""$(openssl rand -base64 16 | tr -dc [:alnum:])"\" >> /vagrant/secure.env
  echo MAX_FAKE_USERS=${MAX_FAKE_USERS} >> /vagrant/secure.env
  echo "Passwords are stored in secure.inc"
fi

# Create our home directories
mkdir -p /export/home

# make sure we always include our secure environment variables for ease of use
echo "[ -f /vagrant/secure.env ] && source /vagrant/secure.env" > /etc/profile.d/vagrant.sh

exit 0
