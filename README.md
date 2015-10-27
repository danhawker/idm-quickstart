# Red Hat Enterprise Linux 7 -- Identity Management Quickstart

<!-- MarkdownTOC depth=4 autolink=true bracket=round -->

- [Introduction](#introduction)
- [Table of Contents](#table-of-contents)
  - [Basic Deployment](#basic-deployment)
  - [Advanced Topics](#advanced-topics)
- [Vagrant Demo](#vagrant-demo)
  - [Notes](#notes)
  - [Start the VMs](#start-the-vms)
  - [Accessing the VMs](#accessing-the-vms)
  - [Login to the VMs](#login-to-the-vms)

<!-- /MarkdownTOC -->

## Introduction

_Please be advised that this quickstart may require Internet access for things
such as downloading updates and other content._

The purpose of this training is to quickly demonstrate Red Hat Identity Management
IT architecture that provides an end-to-end solution for managing centralized users,
groups, host based access controls, roles, password policies and escalated privileges
quickly and reliably for applications and hosts alike.

## Table of Contents
### Basic Deployment
* [Prerequisites](sections/00-prerequisites.md)
* [Installation of Red Hat Identity Management](sections/01-installation.md)
* [Managing Identity: Users, Hosts, and Groups](sections/02-managing-identity.md)
* [Joining Clients](sections/03-joining-clients.md)
* [Managing Policy](sections/04-managing-policy.md)
* [Delegating IdM Privileges (RBAC)](sections/05-role-based-access)

### Advanced Topics
* Adding additional IdM Servers (replicas, topology)
* Backup and Restore
* Active Directory Integration (Trust, External Groups, Views)
* Advanced User Features (SSH, OTP, Views)
* Advanced Host Features (SSH, SSL)
* Managing Network Services (Automount, DNS)

## Vagrant Demo
For your convenience, there is a simple Vagrantfile that will stand up the
quick start environment using CentOS 7 and FreeIPA.  It will be stood up with
a decent number of users and groups, mostly super heroes and super villians.
The [Vagrant Demo Script](vagrant-demo/README.md) will walk through several
real use cases encountered in the dual Marvel and DC comic universes.

### Notes
* !! Do not use this for production workloads !!
* IDM Passwords will be randomly generated and stored in ```secure.env``` alongside the ```Vagrantfile```
* Users and their random passwords generated will stored in ```users.txt``` alongside the ```Vagrantfile```

### Start the VMs
To get the VMs up and running, you need Vagrant, a hypervisor and then run:
```vagrant up```

Watch the output, and if it's your first time, note that it may take a LONG time
to get enough entropy to for some of the Kerberos encryption and SSL stuffs.  You
can speed it up by logging into the VM and playing "smash your face on the keyboard".

### Accessing the VMs
Once the VMs are up, you are able to login to each machine by running:
* IDM Master
** ```vagrant ssh idm_1```
* IDM Replica
** ```vagrant ssh idm_2```
* IDM Client
** ```vagrant ssh client7_1```
* IDM Client
** ```vagrant ssh client6_1```


### Login to the VMs
