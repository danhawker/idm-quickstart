#!/bin/bash

echo "provision.sh"

NETWORK_DEVICE="System eth0"

# use a default of example.test if not specified
DOMAIN=${DOMAIN:-example.test}

# specify some IPs for our IPs
IP_CIDR="172.17.0.0/24"
IP_IDM_1="172.17.0.2"
IP_NFS="172.17.0.4"
IP_CLIENT7_1="172.17.0.9"
IP_CLIENT6_1="172.17.0.19"

# set up some dns stuffs
DNS_REVERSE_ZONE="0.17.172.in-addr.arpa."
DNS_FORWARDERS="8.8.8.8 8.8.4.4"

# set a max of fake users (up to 50000)
MAX_FAKE_USERS=100

# create a new set of passwords to be used for our installation
if [ ! -f  ./secure.env ]; then
  echo "Generating new passwords for use with our setup..."
  echo DOMAIN=\"${DOMAIN}\" >>  ./secure.env
  echo REALM=\"$(echo ${DOMAIN} | tr [a-z] [A-Z])\" >>  ./secure.env
  echo NETWORK_DEVICE=\"${NETWORK_DEVICE}\" >>  ./secure.env
  echo IP_CIDR=\"${IP_CIDR}\" >>  ./secure.env
  echo IP_IDM_1=\""${IP_IDM_1}"\" >>  ./secure.env
  echo IP_NFS=\""${IP_NFS}"\" >>  ./secure.env
  echo IP_CLIENT7_1=\""${IP_CLIENT7_1}"\" >>  ./secure.env
  echo IP_CLIENT6_1=\""${IP_CLIENT6_1}"\" >>  ./secure.env
  echo DNS_REVERSE_ZONE=\""${DNS_REVERSE_ZONE}"\" >>  ./secure.env
  echo DNS_FORWARDERS=\""${DNS_FORWARDERS}"\" >>  ./secure.env
  echo DM_PASSWORD=\""$(openssl rand -base64 16 | tr -dc [:alnum:])"\" >>  ./secure.env
  echo ADMIN_PASSWORD=\""$(openssl rand -base64 16 | tr -dc [:alnum:])"\" >>  ./secure.env
  echo MAX_FAKE_USERS=${MAX_FAKE_USERS} >>  ./secure.env
  echo "Passwords are stored in secure.inc"
fi

exit 0

