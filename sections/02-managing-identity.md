# Managing Identity: Users, Hosts, and Groups

<!-- MarkdownTOC depth=4 autolink=true bracket=round -->

- [Create Users from the Command Line](#create-users-from-the-command-line)
- [```](#)
- [Create Users from the Web GUI](#create-users-from-the-web-gui)
- [Create User Groups from the CLI](#create-user-groups-from-the-cli)
- [Create User Groups from the Web GUI](#create-user-groups-from-the-web-gui)
- [Create Hosts from the Command Line](#create-hosts-from-the-command-line)
- [Create Hosts from the Web GUI](#create-hosts-from-the-web-gui)
- [Create Host Groups from the Command Line](#create-host-groups-from-the-command-line)
- [Create Host Groups from the Web GUI](#create-host-groups-from-the-web-gui)
- [Create Automember Groups from the Command Line](#create-automember-groups-from-the-command-line)
- [Create Automember Groups from the Web GUI](#create-automember-groups-from-the-web-gui)

<!-- /MarkdownTOC -->

## Create Users from the Command Line

Create a bunch of users with randomly generated passwords!

```
ipa user-add --random --first="Clark" --last="Kent" "superman"
ipa user-add --random --first="Peter" --last="Parker" "spiderman"
ipa user-add --random --first="Hal" --last="Jordan" "greenlantern"
ipa user-add --random --first="Lorena" --last="Marquez" "aquagirl"
ipa user-add --random --first="Toni" --last="Monetti" "argent"
ipa user-add --random --first="Jack" --last="Keaton" "armor"
ipa user-add --random --first="Jim" --last="Randall" "atlas"
ipa user-add --random --first="William" --last="Burns" "atomicthunderbolt"
ipa user-add --random --first="Catherine" --last="Bell" "badkitty"
ipa user-add --random --first="Sean" --last="Cassidy" "banshee"
ipa user-add --random --first="Barbara" --last="Gordon" "batgirl"
ipa user-add --random --first="Bruce" --last="Wayne" "batman"
ipa user-add --random --first="Kathy" --last="Kane" "batwoman"
ipa user-add --random --first="Hank" --last="McCoy" "beast"
ipa user-add --random --first="Steve" --last="Rogers" "captainamerica"
```

For each user, you'll see output like:

```
---------------------
Added user "jpreston"
---------------------
  User login: jpreston
  First name: Josh
  Last name: Preston
  Full name: Josh Preston
  Display name: Josh Preston
  Initials: JP
  Home directory: /home/jpreston
  GECOS: Josh Preston
  Login shell: /bin/bash
  Kerberos principal: jpreston@EXAMPLE.TEST
  Email address: jpreston@example.test
  Random password: alORrWkh@BwW
  UID: 1634200017
  GID: 1634200017
  Password: True
  Member of groups: ipausers
  Kerberos keys available: True
```

You will want to provide the ```Random password``` to the end user and they will
be forced to change it upon first login.

## Create Users from the Web GUI
TODO: I don't really ever do this...

## Create User Groups from the CLI
## Create User Groups from the Web GUI

## Create Hosts from the Command Line
## Create Hosts from the Web GUI
## Create Host Groups from the Command Line
## Create Host Groups from the Web GUI

## Create Automember Groups from the Command Line
## Create Automember Groups from the Web GUI
