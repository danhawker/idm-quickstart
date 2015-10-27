# Prerequisites

## Lab Overview
We're going to be building 3 systems: one master, one replica and one client.
These directions will produce the following systems:

| hostname               | ip          | roles                        |
|------------------------|-------------|------------------------------|
| idm-1.example.test     | 172.17.0.2  | RHEL 7 IDM Master            |
| idm-2.example.test     | 172.17.0.3  | RHEL 7 IDM Replica (Master)  |
| client7-1.example.test | 172.17.0.9  | RHEL 7 IDM Client            |
| client6-1.example.test | 172.17.0.19 | RHEL 6 IDM Client            |

![Infrastructure Overview](infrastructure-diagram.png "Infrastructure Overview")

## Lab Environment
You need to have a working Vagrant environment.  This usually involves downloading
and installing vagrant from [vagrantup.com](http://vangrantup.com).

You'll also need a supported hypervisor, such as KVM / libvirt or VirtualBox.

* A dedicated DNS name space ( this Quickstart will use "example.test" )
* A /28 (or larger) subnet ( this Quickstart will use "172.17.0.0/28" )
* Three physical or virtual servers:
	* Red Hat Enterprise Linux 7 (RHEL7)
	* "Minimal Install"
	* 10 GB storage
	* 1 GB RAM
	* 1 CPU (or vCPU)

### Notes
* DNS name space can be delegated as a DNS zone (though delegation is unnecessary without access from outside the lab environment)

## Lab Systems
* 172.17.0.2 : idm-1.example.test
* 172.17.0.3 : idm-2.example.test
* 172.17.0.9 : client7-1.example.test
* 172.17.0.19 : client6-1.example.test

## Lab Client
A desktop with an SSH client and a web browser (Firefox recommended).
