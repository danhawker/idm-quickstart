# Red Hat Enterprise Linux 7 -- Identity Management Quickstart

<!-- MarkdownTOC depth=4 autolink=true bracket=round -->

- [Introduction](#introduction)
- [Basic Deployment](#basic-deployment)
- [Advanced Topics](#advanced-topics)
- [Demonstration](#demonstration)
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
quickly and reliably.

Assuming you would like to perform all of the steps manually, you will first want
to start with the [Basic Deployment](#basic-deployment) and then move on to the
more [Advanced Topics](#advanced-topics).  Afterwards, you will have a suitable
environment for

## Basic Deployment

* [Prerequisites](sections/00-prerequisites.md)
* [Installation of Red Hat Identity Management](sections/01-installation.md)
* [Managing Identity: Users, Hosts, and Groups](sections/02-managing-identity.md)
* [Joining Clients](sections/03-joining-clients.md)
* [Managing Policy](sections/04-managing-policy.md)
* [Delegating IdM Privileges (RBAC)](sections/05-role-based-access.md)

## Advanced Topics
* [Adding additional IdM Servers (replicas, topology)](sections/06-install-replica.md)
* [Backup and Restore](sections/07-backup-and-restore.md)
* [Active Directory Integration (Trust, External Groups, Views)](sections/08-active-directory-integration.md)
* [Advanced User Features (SSH, OTP, Views)](sections/09-advanced-user-features.md)
* [Advanced Host Features (SSH, SSL)](sections/10-advanced-host-features.md)
* [Managing Network Services (Automount, DNS)](sections/11-managing-network-services.md)

## Demonstration

### Vagrant Demo
For your convenience, there is a simple Vagrantfile that will stand up the
quick start environment using CentOS 7 and FreeIPA.  It will be stood up with
a decent number of users and groups, mostly super heroes and super villians.
The [Vagrant Demo Script](vagrant-demo/README.md) will walk through several
real use cases with generated data.

### Notes
* !! Do not use this for production workloads !!
* IDM Passwords will be randomly generated and stored in ```secure.env``` alongside the ```Vagrantfile```
* Users are generated using data stored in ```fake-users.csv``` alongside the ```Vagrantfile```

### Start the VMs
To get the VMs up and running, you need Vagrant, a hypervisor and then run:
```vagrant up```

Watch the output, and if it's your first time, note that it may take a LONG time
to get enough entropy to for some of the Kerberos encryption and SSL stuffs.  You
can speed it up by logging into the VM and playing "smash your face on the keyboard".

### Accessing the VMs
Once the VMs are up, you are able to login to each machine by running:
* IDM Master
 * ```vagrant ssh idm_1```
* IDM Replica (if you uncommented it in the Vagrantfile)
 * ```vagrant ssh idm_2```
* IDM NFS Server
 * ```vagrant ssh nfs```
* IDM Client 7
 * ```vagrant ssh client7_1```
* IDM Client 6 (if you uncommented it in the Vagrantfile)
 * ```vagrant ssh client6_1```

### Login to the VMs
