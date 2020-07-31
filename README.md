# MailAD

This is a handy tool to provision a mail server on linux linked to an Active Directory server (Samba or Windows, it does not care) with some constraints in mind, as this is a typical mail config to be used in Cuba under certain laws and security requirements

## Rationale

This repository is intended to be cloned on your fresh OS install under `/root` (you can use a LXC instance, VM, CT, etc) and setup on a main conf file as per the file comments, then run the steps on a makefile and follow the steps to configure your server.

After a few steps you will have a mail server up and running in about 15 minutes tops. _(this time is based on a 2Mbps internet connection to a repository, if you have a local repository it will be less)_

This tool is tested and supported on:

- Ubuntu Bionic 18.04 (last LTS)
- Ubuntu Focal 20.04 (Actual LTS and actual dev env)
- Debian Buster 10 (Stable)

It's recommended that the instance of MailAD sits inside your DMZ net with a firewall between it and your users and a mail gateway like [Proxmox Mail Gateway](https://www.proxmox.com/en/proxmox-mail-gateway) between it and the outside world

## Features

This will provision a mail server in a enterprise/SOHO as a real server facing the users and behind a Mail Gateway to the outside world, you can see the major features in the [Features.md](Features.md) file, among others you will find:

0. Low resource footprint
0. Automatic alias using AD groups
0. Optional user privilege access via AD groups (local/national/international)
0. Manual alias to handle typos or enterprise positions
0. Manual ban list for trouble some address (aka blacklist)
0. Manual headers & body checks lists
0. Painless upgrades

## TODO

There is a [TODO list](TODO.md), a kind of a "roadmap" for new features, but as I (only one dev so far) have a life, a family and a daily job, you know...

All dev is made on weekend or late at night (seriously take a peek on the commit dates!) if you need a feature or fix ASAP, please take into account making a donation or found me and I will be happy to help you, my contact info is on the bottom of this page

## Constraints and requirements

Remember the comment at top of the page about _"...with some constraints in mind..."_ yeha, here they are:

0. Your user base and config came from an Active Directory (AD from now on) as mentioned, we prefer a Samba AD but works on Windows too; see [AD requirements for this tool](AD_Requirements.md)
0. The mail storage will be a folder in `/home/vmail`, all mail will belong to a user named `vmail` with uid:5000 & gid:5000. Tip: that folder can be a NFS mount or any other type of network storage
0. You use a Windows PC to control and manage the domain (must be a domain member and have the RSAT installed and activated), we recommend a Windows 10 LTSC/Professional
0. The server allows all communications protocols by default _(POP3, POP3S, IMAP, IMAPS, SMTP, SSMTP and SUBMISSION)_ it's **up to you** to restrict the users access in a way that them just use the secure versions (POP3S, IMAPS & SUBMISSION. Take into account that the SMTP service must be used only to send/receive the emails from the outside world)

## Technical details

For debug and test purposes we use this config:

### Samba/Windows Active Directory PC

- IP: 10.42.0.2/24
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

To avoid permission problems we recommend you to held the files under the /root directory, so from this moment and forward you need to be root to runs the following commands, `sudo -i` is your friend if you are not root.

### Initial setup

Just update and upgrade your system, install one dependency and clone this repository under /root

**Warning! the recommended branch for productions environments is the master branch, don't use any other branch on production!**

``` sh
cd /root
apt update
apt install make -y
git clone https://github.com/stdevPavelmc/mailad
cd mailad
git checkout master
git pull
```

## Prepare your server

To prepare your server to install you need to first create the default config, just run this command:

``` sh
make conf
```

This step will create the folder /etc/mailad and place a default mailad.conf file on it, now you are ready yo start

### Initial config

Read and fill all needed variables on the `/etc/mailad/mailad.conf` file, please read carefully and choose wisely!

_At this point the fast & furious ones can just run `make all` and follow the clues, the rest of the mortals just follow the next steps_

### Dependencies handling

Call the dependencies to install all the needed tools, like this

``` sh
make deps
```

This will install a group of needed tools to run the provision scripts, if all goes well no error must be shown; if an error is shown then you must work it out as it will be 99% of the time a problem related to the repository link and update

### Checks

Once you have installed the dependencies it's time to check the local config for errors

``` sh
make conf-check
```

This will check for some of the pre-defined scenarios and configs, if any problem is found you will be warned about, otherwise we are ready to install

Oh wait! We need to generate the SSL certificates first.

### Certificate creation

All client communications in this setup will be encrypted, so you will need at least a self signed certificate for internal use. This certificate will be used by postfix & dovecot

IF you proceed MailAD script will generate a self-signed certificate that will last for 10 years, or if you have a cert from Let's Encrypt (LE for short) (standalone or wildcard) you can use it also. In the case you have a LE cert, using it is simple:

Just pick the ones that are named "fullchain*" and "privkey*" and place them on the folder `/etc/mailad/le/` and name it like this: `fullchain.pem` and `privkey.pem` and the provision scripts will use it


``` sh
make certs
```

Final certs will lay on this places (if LE then certs will be copied over & secured):

- Certificate: `/etc/ssl/certs/mail.crt`
- Private Key: `/etc/ssl/private/mail.key`
- CA certificate: `/etc/ssl/certs/cacert.pem`

If you obtain a LE certs for your server after using the self-signed or you need to update them; then just place them (like we described above) on the `/etc/mailad/le/` folder on the config and do the following from the folder you have the cloned MailAD install

``` sh
rm certs &2> /dev/null
make certs
systemctl restart postfix dovecot
systemctl status postfix dovecot
```

The last two steps restart the services and shows it's state for you to check if all gone well, if you get in trouble just remove the files from the `/etc/mailad/le/` and repeat the above steps, that will re-create a self signed certificate and place it on service

### Software installs

``` sh
make install
```

This step installs all the needed softwares, be ware that we **ALWAYS** purge the soft and old configs in this step; in this way we always start with a fresh set of files for the provision stage. If you have a non clean environment the script will suggest steps to make it clean

### Services provision

After the software install you must provision the configuration, that's accomplished with a single command:


``` sh
make provision
```

This stage will copy the template files in the var folder of this repo replacing the values with the ones in your `mailad.conf` file. If any problem is found you will be warned about it and will need to re-run the command `make provision` to continue. There is also a `make force-provision` target in case you need to force the provision by hand

When you reach a success message after the provision you are ready to test your new mail server, congrats!

## This is free software

Have a comment, question, contributions or fix?

Don't hesitate, use the Issues tab in the repository URL or drop me a message via my social media accounts:

- Twitter: @co7wt
- Telegram: @pavelmc

We have a file to register the contributions to this Software, you can check it [here](Contributors.md)
