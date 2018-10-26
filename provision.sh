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

# make sure all hosts can be found
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "${IP_IDM_1}  idm-1.${DOMAIN} idm-1" >> /etc/hosts
echo "${IP_NFS}  nfs.${DOMAIN} nfs" >> /etc/hosts
echo "${IP_CLIENT7_1}  client7-1.${DOMAIN} client7-1" >> /etc/hosts
echo "${IP_CLIENT6_1}  client6-1.${DOMAIN} client6-1" >> /etc/hosts

# create a new set of passwords to be used for our installation
if [ ! -f /vagrant/secure.env ]; then
  echo "Error, you didn't generate configurations or passwords for use with our setup... modify and run config.sh from the host"
  exit -1
fi

# Create our home directories
mkdir -p /export/home

# make sure we always include our secure environment variables for ease of use
echo "[ -f /vagrant/secure.env ] && source /vagrant/secure.env" > /etc/profile.d/vagrant.sh

exit 0
