# MailAD

This is a handy tool to provision a mail server on linux linked to an Active Directory server (Samba or Windows, it does not care) with some constraints in mind, as this is a typical mail config to be used in Cuba under certain laws and security requirements.

## Rationale

This repository is intended to be cloned on your fresh OS install under `/root` (you can use a LXC instance, VM, CT, etc) and setup on a main conf file as per the file comments, then run the steps on a makefile and follow the steps to configure your server.

After a few steps you will have a mail server up and running in about 15 minutes tops. _(this time is based on a 2Mbps internet connection to a repository, if you have a local repository it will be less)_

## Features

This will provision a mail server in a enterprise/SOHO as a real server facing the users and behind a Mail Gateway to the outside world, you can see the major features in the [Features.md](Features.md) file, among others you will find:

0. Low resource footprint
0. Automatic alias using AD groups (without the snowball effect)
0. Optional user privilege access via AD groups (local/national/international)
0. Manual alias to handle typos or enterprise positions
0. Manual ban list for trouble some address (aka blacklist)
0. Manual headers & body checks lists
0. Painless upgrades

## TODO

There is a [TODO list](TODO.md), a kind of a "roadmap" for new features, but as I (only one dev so far) have a life, a family and a daily job, you know...

All dev is made on weekend or late at night (seriously take a peek on the commit dates!) if you need a feature or fix ASAP, please take into account making a donation or found me and I will be happy to help you, my contact info is on the bottom of t his page

## Constraints and requirements

Remember the comment at top of the page about _"...with some constraints in mind..."_ yeha, here they are:

0. Your user base and config came from an Active Directory (AD from now on) as mentioned, we prefer a Samba AD but works on Windows too; see [AD requirements for this tool](AD_Requirements.md)
0. The mail storage will be a folder in `/home/vmail`, all mail will belong to a user named `vmail` with uid:5000 & gid:5000. Tip: that folder can be a NFS mount or any other type of network storage
0. You use a Windows PC to control and manage the domain (must be a domain member and have the RSAT installed and activated), we recommend a Windows 10 LTSC/Professional
0. For now all users have international access, national and local restrictions will be supported in the near term
0. The server allows all communications protocols by default _(POP3, POP3S, IMAP, IMAPS, SMTP, SSMTP and SUBMISSION)_ it's **up to you** to restrict the users access in a way that them just use the secure versions (POP3S, IMAPS & SUBMISSION. Take into account that the SMTP service must be used only to send/receive the emails from the outside world)
0. Tested and developed under Ubuntu 18.04 LTS, you need to get access to a repository for the package installation
0. Testing over Ubuntu 20.04 is stating as June 2020, full support must be no later than August/2020, Debian 10 support is on the TODO list after completion of a few issues.

## Technical details

For debug and test purposes we use this config, **you need to change it on the `mailad.conf` file!**

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

**Security warning:** As the config file has passwords in clear text it must be held under the /root directory, so from this moment and forward you need to be root to runs the following commands, `sudo -i` is your friend if you are not root.

### Initial setup

Just update and upgrade your system, install one dependency and clone this repository under /root (see above Security warning note) Here you has and example:

**Warning! the recommended branch for productions environments is the master branch, don't use the development branch on production!**

``` sh
cd /root
sudo apt update
sudo apt install make -y
git clone https://github.com/stdevPavelmc/mailad
cd mailad
git checkout master
git pull
```

### initial config

Read and fill all needed variables on the `mailad.conf` file, please read carefully and choose wisely!

_At this point the fast & furious ones can just run `make all` and follow the clues, the rest of the mortals just follow the next steps_

### Dependencies handling

Call the dependencies to install all the needed tools, like this

``` sh
make deps
```

This will install a group of needed tools to run the provision scripts, if all goes well no error must be shown; if an error is shown then you must work it out as it will be 99% of the time a problem related to the repository link and update

### Checks

Once you have installed the dependencies it's time to check the local config for errors.

``` sh
make conf-check
```

This will check for some of the pre-defined scenarios and configs, if any problem is four you will be warned about, otherwise we are ready to install

Oh wait! We need to generate the SSL certificates first.

### Certificate creation

All communications with the clients in this setup will be encrypted, so you will need at least a self signed certificate for internal use. This certificate will be used by postfix & dovecot


``` sh
make certs
```

If you have a custom certificate, then just use the generated one during config and test stage, and at the end replace it with yours, the certs are in:

- Certificate: `/etc/ssl/certs/mail.crt`
- Private Key: `/etc/ssl/private/mail.key`
- CA certificate: `/etc/ssl/certs/cacert.pem`

If you have a Let's Encrypt certificate for your server (or a wildcard one) just place them in `/root/certs`, erase those files and link them to the actual ones

The mapping is as this:

- fullchain.pem > `/etc/ssl/certs/mail.crt`
- fullchain.pem > `/etc/ssl/certs/cacert.pem`
- privkey.pem > `/etc/ssl/private/mail.key`

### Software installs

``` sh
make install
```

This step installs all the needed softwares, be ware that we **ALWAYS** purge the soft and old configs in this step; in this way we always start with a fresh set of files for the provision stage

### Services provision

After the software install you must provision the configuration from the mailad.conf file, that is accomplished with a single command


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
