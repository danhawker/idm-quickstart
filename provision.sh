#!/bin/bash

echo "provision.sh"

# Do an upgrade of packages
yum -y upgrade

# use a default of example.test if not specified
DOMAIN=${DOMAIN:-example.test}

# specify some IPs for our IPs
IP_CIDR="172.17.0.0/24"
IP_IDM_1="172.17.0.2"
IP_IDM_2="172.17.0.3"
IP_CLIENT7_1="172.17.0.9"

# set up some dns stuffs
DNS_REVERSE_ZONE="0.17.172.in-addr.arpa."
DNS_FORWARDER="8.8.8.8"

# make sure all hosts can be found
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "${IP_IDM_1}  idm-1.${DOMAIN} idm-1" >> /etc/hosts
echo "${IP_IDM_2}  idm-2.${DOMAIN} idm-2" >> /etc/hosts
echo "${IP_CLIENT7_1}  client7-1.${DOMAIN} client7-1" >> /etc/hosts

# create a new set of passwords to be used for our installation
if [ ! -f /vagrant/secure.env ]; then
  echo "Generating new passwords for use with our setup..."
  echo DOMAIN=\"${DOMAIN}\" >> /vagrant/secure.env
  echo REALM=\"$(echo ${DOMAIN} | tr [a-z] [A-Z])\" >> /vagrant/secure.env
  echo IP_CIDR=\"${IP_CIDR}\" >> /vagrant/secure.env
  echo IP_IDM_1=\""${IP_IDM_1}"\" >> /vagrant/secure.env
  echo IP_IDM_2=\""${IP_IDM_2}"\" >> /vagrant/secure.env
  echo IP_CLIENT7_1=\""${IP_CLIENT7_1}"\" >> /vagrant/secure.env
  echo DNS_REVERSE_ZONE=\""${DNS_REVERSE_ZONE}"\" >> /vagrant/secure.env
  echo DNS_FORWARDER=\""${DNS_FORWARDER}"\" >> /vagrant/secure.env
  echo DM_PASSWORD=\""$(openssl rand -base64 16 | tr -dc [:alnum:])"\" >> /vagrant/secure.env
  echo MASTER_PASSWORD=\""$(openssl rand -base64 16 | tr -dc [:alnum:])"\" >> /vagrant/secure.env
  echo ADMIN_PASSWORD=\""$(openssl rand -base64 16 | tr -dc [:alnum:])"\" >> /vagrant/secure.env
  echo "Passwords are stored in secure.inc"
fi

exit 0
