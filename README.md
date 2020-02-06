# MailAD

MailAD is a tool to provision a mail server using an active directory server (Samba or Windows AD) as a backend. This tool produces a typical mail configuration to be used in Cuba under certain rules and security requirements.

## Rationale

This repository is intended to be cloned on fresh installed operating system (LXC instance, VM, etc) and configured using a main file. You have to run the makefile and follow the steps to configure your server, if everything goes well you will have your mail server up and running in about 30 minutes.

## Constraints and requirements

0. Your user base and configuration will be on a Windows Active Directory (AD from now on) as mentioned, we prefer a Samba AD but works on Windows too; see [the requirements of the AD for this tool](AD_Requirements.md)
0. The mail storage will be a folder in `/home/vmail` all mail will belong to a user named `vmail` with uid:5000 & gid:5000. Tip: that folder can be a NFS mounted on a Docker volume
0. To control and manage the domain a Virtual/Real Windows PC with RSAT installed and activated is needed. We recommend Windows 10 LTSC/Professional.
0. For now, all users have international access, national and local restrictions will be supported later
0. For now, the underlying OS must be Ubuntu 18.04 LTS and you must get access to a repository to install packages.
0. Debian 10 will be supported later
0. The server allows by default these protocols: _(pop3, pop3s, imap, imaps, smtp, smtps and submission)_. It's **up to you** to allow only secure protocols (pop3s, imaps and submission; the smtp service must be used only to receive mail from outside)

## Technical details

For debugging and testing purposes we use this config **you need to change it on the mailad.conf file!**

### Samba/Windows Active Directory PC

- IP: 10.42.0.2/24  (Ubuntu uses netplan for network configuration, check /etc/netplan/*.conf files)
- Hostname: dc.mailad.cu
- Domain NETBIOS name: MAILAD
- Domain DNS name: mailad.cu
- DNS server: 10.42.0.2 `yes, itself`

Special Domain settings are clarified [in a specific file](AD_Requirements.md):

### Ubuntu Mail server

- IP: 10.42.0.3/24
- Hostname: mail.mailad.cu
- DNS server: 10.42.0.2

## How to make it work?

**Security warning:** As the config file has passwords in clear text it must be held under the /root directory, so from now on you need to be root to run the following commands, `sudo -i` is your friend if you are not root.

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

Read and fill all needed variables in the `mailad.conf` file, please read carefully and choose wisely!

At this point the fast & furious ones can just run `make all` and follow the clues, the rest of the mortals just follow the next steps 

### Dependencies handling

Call the dependencies to install all the needed tools, like this

``` sh
make deps
```

This will install a group of tools needed to run the scripts on this software, if everything goes well no error must be shown; if an error is shown, then you must work it out as it will be likely a problem related to packages update process.

### Checks

Once you have installed the dependencies it's time to check the local config for errors.

``` sh
make conf-check
```

This will check for some of the pre-defined scenarios and configs, if any problem is found you will be warned about it, otherwise we are ready to install the software, but first, we need to generate the SSL certificates

### Certificate creation

The communication with the clients in this setup will be encrypted, so you will need at least a self signed certificate for internal use. This certificate will be used by postfix and dovecot


``` sh
make certs
```

If you have a custom certificate, then just use the generated one and at the end replace them, the certs are in:

- Certificate: `/etc/ssl/certs/mail.crt`
- Private Key: `/etc/ssl/private/mail.key`
- CA certificate: `/etc/ssl/certs/cacert.pem`

### Software installs

``` sh
make install
```

This step installs the needed packages, be ware that we **ALWAYS** purge the soft and old configs in this step; in this way we always start with a fresh set of files for the provisioning stage.

### Services provision

After the installation process you must provision the configuration from the mailad.conf file, using the following command


``` sh
make provision
```

This stage will copy the template files in the var folder of this repo replacing the values with the ones in your `mailad.conf` file. If any problem is found you will be warned about it and you will need to re-run the command `make provision` to continue the provisioning. There is also a `make force-provision` target in case you need to force the provision by hand.

When you get a success message after the provisioning you are ready to test your new mail server, congrats!

## This is free software

Have a comment, contributions or fix?

Don't hesitate, use the Issues tab in the repository URL.

We have a file to register the contributions to this Software, you can check it [here](Contributors.md)
