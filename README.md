# MailAD

This a tool to provision a mail server linked to an active directory server (Samba or Windows AD) with some constraints in mind as this is a typical mail config to be used in Cuba under ceirtain Laws and security requirements;

## Rationale

This repository is inteded to be clonated on your fresh OS install (LXC instance, VM, etc) and configured on a main file as per the file comments, then run the steps on a makefile and follow the steps to configure your server, is all goes well you will have your mail server up and running in about 30 minutes.

## Constraints and requirements

0. Your user base and config came from a Windows Active Directory (AD from now on) as mentiones we prefer a Samba AD but works on Windows AD too
0. Your user base is arranged under a special OU in the AC under the NETBIOS domain name
0. For now all users have internacional access, national and local restrictions will be supported in the near term
0. For now the underlaying OS must be Ubuntu 18.04 LTS and you must get access to a repository for the package installation, Debian 10 will be supported in the near term
0. The mail storage will be a folder in `/home/vmail` all mail will belong to a user named `vmail` with uid:5000 & gid:5000. Tip: that folder can be a NFS mount of a Docker volume
0. All mail with the users will be under secure comunications (pop3s, imaps, submission but not smtps)
0. You use a Virtual/Real Windows PC to control and manage the domain (must have the RSAT installed and activated), we recommend a Windows 7 PC, as windows 10 is picky for the RSAT install

## Asumptions

We use a simple user (not admin!) to link the LDAP searches from the linux boxes, the details for this user are show below:

- User name: `linux`
- Password: `Passw0rd!!!` Warning: `(This is the default you must change it!)`
- User must be located on the `Users` default AD tree, NOT in the organizational OU see picture below

Settings for the default PCs

### Samba/Windows Active Directory PC

IP: 10.42.0.2/24  (Ubuntu use netplan for network config check /etc/netplan/mailad.conf)
Hostname: dc.mailad.cu
Domain NETBIOS name: MAILAD
Domain DNS name: mailad.cu

Special Domain settings are clarified below:

[show domain AD tree]

### Ubuntu Mail server

IP: 10.42.0.3/24
Hostname: mail.mailad.cu
