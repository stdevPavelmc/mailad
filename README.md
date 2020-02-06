# MailAD

This is a tool to provision a mail server linked to an active directory server (Samba or Windows active directory, it does not care) with some constraints in mind as this is a typical mail config to be used in Cuba under ceirtain laws and security requirements;

## Rationale

This repository is inteded to be clonated on your fresh OS install (LXC instance, VM, etc) and configured on a main file as per the file comments, then run the steps on a makefile and follow the steps to configure your server, is all goes well you will have your mail server up and running in about 15 minutes tops. _(this time is based on a 2Mbps internet connection to a repository, if you have a local repository it will be much less)_

## Constraints and requirements

0. Your user base and config came from a Windows Active Directory (AD from now on) as mentioned, we prefer a Samba AD but works on Windows too; see [the requirements of the AD for this tool](AD_Requirements.md)
0. The mail storage will be a folder in `/home/vmail` all mail will belong to a user named `vmail` with uid:5000 & gid:5000. Tip: that folder can be a NFS mount or a Docker volume
0. You use a Virtual/Real Windows PC to control and manage the domain (must have the RSAT installed and activated), we recommend a Windows 10 LTSC/Professional.
0. For now all users have international access, national and local restrictions will be supported in the near term.
0. For now the underlying OS must be Ubuntu 18.04 LTS and you must get access to a repository for the package installation.
0. Debian 10 will be supported in the near future if enough interest on this.
0. The server allows all communications protocols by default _(pop3, pop3s, imap, imaps, smtp, smtps and submission)_ it's **up to you** to restrict the users access (firewall) in a way that them just use the secure versions (pop3s, imaps and submission; the smtp service must be used only to send/receive the emails from the outside world)

## Technical details

For debug and test purposes we use this config, **you need to change it on the mailad.conf file!**

### Samba/Windows Active Directory PC

- IP: 10.42.0.2/24  (Ubuntu uses netplan for network config, check /etc/netplan/*.conf files)
- Hostname: dc.mailad.cu
- Domain NETBIOS name: MAILAD
- Domain DNS name: mailad.cu
- DNS server: 10.42.0.2 `yes, itself`

Special Domain settings are clarified [in a specific file](AD_requirements.md):

### Ubuntu Mail server

- IP: 10.42.0.3/24
- Hostname: mail.mailad.cu
- DNS server: 10.42.0.2

## How to make it work?

**Security warning:** As the config file has passwords in clear text it must be held under the /root directory, so from this moment and forward you need to be root to runs the following commands, `sudo -i` is your friend if you are not root.

### Initial setup

Just update and upgrade your system, install one dependency and clone this repository under /root (see above Security warning note)

**Warning! the recomended branch for productions environments is the master branch, don't use the development branch on production!**

``` sh
cd /root
sudo apt update
sudo apt install make -y
git clone https://github.com/stdevPavelmc/mailad
git checkout master
cd mailad
```

### initial config

Read and fill all needed variables on the `mailad.conf` file, please read carefully and choose wisely!

_At this point the fast & fourious ones can just run `make all` and follow the clues, the rest of the mortals just follow the next steps_

### Dependencies handling

Call the dependencies to install all the needed tools, like this

``` sh
make deps
```

This will install a group of needed tools to run the scripts on this software, is all goes well no error must be shown; if an error is shown then you must work it out as it will be 99% of the time a problem related to the repository link and update.

### Checks

Once you have installed the dependencies it's time to check the local config for errors.

``` sh
make conf-check
```

This will check for some of the pre-defined scenarios and configs, if any problem is four you will be warned about, otherwise we are ready to install...

Oh wait! We need to generate the SSL certificates first.

### Certificate creation

All communications with the clients in this setup will be encrypted, so you will need at least a self signed certificate for internal use. This certificate will be used by postfix & dovecot


``` sh
make certs
```

If you have a custom certificate, then just use the generated one during config and test stage, and at the end replace ir with your's, the certs are in:\

- Certificate: `/etc/ssl/certs/mail.crt`
- Private Key: `/etc/ssl/private/mail.key`
- CA certificate: `/etc/ssl/certs/cacert.pem`

### Software installs

``` sh
make install
```

This step installs all the needed softwares, be ware that we **ALWAYS** purge the soft and old configs in this step; in this way we always start with a fresh set of files for the provision stage.

### Services provision

After the install you must provision the configuration from the mailad.conf file, that is accomplished with a single command


``` sh
make provision
```

This stage will copy the template files in the var folder of this repo replacing the values with the ones in your `mailad.conf` file. If any problem is found you will be warned about it and will need to re-run the command `make provision` to continue the provision. There is also a `make force-provision` target in case you need to force the provision by hand.

When you reach a success message after the provision you are ready to test your new mail server, congrats!

## This is free software

Have a comment, contributions or fix?

Don't hesitate, use the Issues tab in the repository URL.

We have a file to register the contributions to this Software, you can check it [here](Contributors.md)
