# Connecting clients to IdM

<!-- MarkdownTOC depth=4 autolink=true bracket=round -->

- [Install Red Hat Identity Management Client Software](#install-red-hat-identity-management-client-software)
- [Join the RHEL7 client to the IdM environment](#join-the-rhel7-client-to-the-idm-environment)

<!-- /MarkdownTOC -->

## Install Red Hat Identity Management Client Software
Let's go ahead and install the client software on our client systems:

* client7-1.example.test
* client6-1.example.test

Install the necessary packages:
```
yum -y install ipa-client
```

## Join the RHEL7 client to the IdM environment

