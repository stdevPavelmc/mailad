# MailAD

This a tool to provision a mail server linked to an active directory server (Samba or Windows AD) with some constraints in mind as this is a typical mail config to be used in Cuba under ceirtain Laws and security requirements;

## Rationale

This repository is inteded to be clonated on your fresh OS install (LXC instance, VM, etc) and configured on a main file as per the file comments, then run the steps on a makefile and follow the steps to configure your server, is all goes well you will have your mail server up and running in about 30 minutes.

## Constraints and requirements

0. Your user base and config came from a Windows Active Directory (AD from now on) as mentioned, we prefer a Samba AD but works on Windows AD too
0. Your user base is arranged under a special OU in the AC under the NETBIOS domain name
0. The mail storage will be a folder in `/home/vmail` all mail will belong to a user named `vmail` with uid:5000 & gid:5000. Tip: that folder can be a NFS mount of a Docker volume
0. You use a Virtual/Real Windows PC to control and manage the domain (must have the RSAT installed and activated), we recommend a Windows 7 PC, as windows 10 is picky for the RSAT install.
0. For now all users have international access, national and local restrictions will be supported in the near term
0. For now the underlying OS must be Ubuntu 18.04 LTS and you must get access to a repository for the package installation, Debian 10 will be supported in the near term
0. All mail with the users will be under secure comunications (pop3s, imaps, submission but not smtps)

## Assumptions

We use a simple user (not admin!) to link the LDAP searches from the linux boxes, the details for this user are show below:

- User name: `linux`
- Password: `Passw0rd!!!` Warning: `(This is the default you must change it!)`
- User must be located on the `Users` default AD tree, NOT in the organizational OU see picture below

Settings for the default PCs

### Samba/Windows Active Directory PC

- IP: 10.42.0.2/24  (Ubuntu use netplan for network config check /etc/netplan/mailad.conf)
- Hostname: dc.mailad.cu
- Domain NETBIOS name: MAILAD
- Domain DNS name: mailad.cu
- DNS server: 10.42.0.2 `yes, itself`

Special Domain settings are clarified below:

[show domain AD tree]

### Ubuntu Mail server

- IP: 10.42.0.3/24
- Hostname: mail.mailad.cu
- DNS server: 10.42.0.2 `yes, itself`

## How to make it work?

**From this point forward you must work as root user**

### Initial setup

Just clone this repository under the place you like, your home is a good place

``` sh
cd ~
git clone https://github.com/stdevPavelmc/mailad
cd mailad
```

### initial config

Read and fill all needed variables on the `mailad.conf` file, please read carefully and choose wisely!

### Dependencies handling

Call the dependencies to install all the needed tools, like this

``` sh
make deps
```

This will install a group of needed tools to run the scripts on this software, is all goes well no error must be shown; if an error is shown then you must work it out, as it will be 99% of the time a problem related to the repository link and update.

### Checks

Once you have installed the dependencies it's time to check the config file basics

``` sh
make conf-check
```

This will check for some of the pre-defined scenarios and configs, if any problem is four you will be warned about, otherwise we a re ready to install the softs

### Software installs

``` sh
make install
```

This step installs all the needed softwares with the provision of making a backup of the old config folders if there is a previous config on the server, folders will be named like this `postfix-20191112_234590` as you can see a timestamp is added to the folders

### Certificate creation

All communications with the clients in this setup will be encrypted, so you will need a self signed certificate for internal use, in this step a few lines of info will be asked, if it fails just re-run the command until it works. This certificate will be used by postfix & dovecot


``` sh
make certs
```

### Services provision

After the install you must provision the configuration from the mailad.conf file, that is accomplished with a single command


``` sh
make provision
```

This stage will copy the template files in the var folder of this repo replacing the values with the ones in your `mailad.conf` file.

If any problem is found you will be warned about and will need to re-run the command to continue the provision.

When you reach a success message after the provision you can run and test your mail server, congrats!

