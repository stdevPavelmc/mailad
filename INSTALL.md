# MailAD Installation Instructions

This page is also available in the following languages: [ [Español](i18n/INSTALL.es.md) 🇪🇸 🇨🇺] [ [Deutsch](i18n/INSTALL.de.md) 🇩🇪] *Warning: translations may be outdated.*

Check this [simple console recording](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8) to see how a regular install looks.

⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️

**WARNING:** Since the end of February 2021 we simplified the integration with AD, you **need** to check [this document](Simplify-AD-config.md) if you want to upgrade your old setup.

Users of new installs will not have issues, just follow the install procedure below and you will be safe.

## A notice on OS Support

It's adviced to install MailAD on the latest LTS of Ubuntu or a latest stable from Debian, any older distro is supported (see README for OS support matrix) but not recommended for new installs, just for operations and upgrades.

What if I have MailAD installed on an older distro like 2 Ubuntu LTS or 2 Debian releases behind?

Easy: just upgrade the distro to the latest release (follow preferred way for your distro), reboot and then do a `make force-provision` on the MailAD repo folder. Just that.

**Notice:** You must prevent the users to use the Mail services during the upgrades process, otherwise users may lose their mailboxes due to corruption.

## Introduction & Checks

To avoid permission problems we recommend you to held the files under the `/root` directory, so from this moment and forward you need to be root to run the following commands, `sudo -i` is your friend if you are not root.

If you are behind a proxy remember you can use apt over it to update, upgrade and install the needed apps. Just export the following variables and all traffic will be routed to the external network through your declared proxy, here you have an example:

``` sh
export http_proxy="http://user:password@proxy.enterprise.cu:3128/"
export https_proxy="http://user:password@proxy.enterprise.cu:3128/"
```

You need to setup a proxy also for git tor work, just do this (If not done already):

``` sh
echo "[http]" >> ~/.gitconfig
echo "    proxy = http://user:password@proxy.enterprise.cu:3128/" >> ~/.gitconfig
```

If your setup use a proxy without username and password authentication just omit the "user:password@" part in the lines above, like this: `http://proxy.enterprise.cu:3128/`

Remember to substitute `user`, `password`, `proxy.enterprise.cu` (proxy server fully qualified domain name) and `3128` (port) with the correct values for your environment.

## Initial Setup

Just update and upgrade your system, install dependencies and clone this repository under `/root`, like this:

**Warning! the recommended branch for productions environments is the master branch, don't use any other branch on production!**

``` sh
cd /root
apt update
apt upgrade
apt install git make -y
git clone https://github.com/stdevPavelmc/mailad
cd mailad
git checkout master
git pull
```

## Prepare Your Server

To prepare your server for installation you need to first create the default config. For that just run this command:

``` sh
make conf
```

This step will create the folder /etc/mailad and place a default mailad.conf file on it. Now you are ready yo start configuring your system.

## Initial Config

Read and fill all needed variables on the `/etc/mailad/mailad.conf` file, please read carefully and choose wisely!

_At this point the fast & furious ones can just run `make all` and follow the clues, the rest of the mortals just follow the next steps_

## Dependencies Handling

Call the dependencies to install all the needed tools, like this:

``` sh
make deps
```

This will install a group of needed tools to run the provision scripts, if all go well no error must be shown; if an error is shown then you must work it out as it will be 99% of the time a problem related to the repository link and updates.

## Checks

Once you have installed the dependencies it's time to check the local config for errors:

``` sh
make conf-check
```

This will check for some of the pre-defined scenarios and configs, if any problem is found you will be warned about it.

### Most Common Pitfalls

- Hostname: your server need to know your full qualified hostname see [this tutorial](https://gridscale.io/en/community/tutorials/hostname-fqdn-ubuntu/) to know how to solve that issue
- ldapsearch errors: 100% of the time is due to a typo on the mailad.conf file, check it carefully

We are ready to install now... Oh wait! We need to generate the SSL certificates first ;-)

## Certificate Creation

All client communications must be encrypted, so you will need at least a self signed certificate for internal use. This certificate will be used by postfix & dovecot.

If you proceed MailAD script will generate a self-signed certificate that will last for 10 years, or if you have certificates from Let's Encrypt (LE for short) you can use them also, standalone and wildcard are both good options.

In case you have LE certificates, using them is simple. Just pick those named "fullchain*" and "privkey*" and place them on folder `/etc/mailad/le/`, name them `fullchain.pem` and `privkey.pem` respectively so the provision scripts could use them.

``` sh
make certs
```

Final certificates will lay on this place (if your are using LE certificates will be copied over & secured):

- Certificate: `/etc/ssl/certs/mail.crt`
- Private Key: `/etc/ssl/private/mail.key`
- CA certificate: `/etc/ssl/certs/cacert.pem`

If you obtain LE certificates for your server after the use of self-signed ones, you need to update or replace them. Then just place them (like we described above) on the `/etc/mailad/le/` folder on the config and do the following from the folder you have cloned the MailAD install:

``` sh
rm certs &2> /dev/null
make certs
systemctl restart postfix dovecot
systemctl status postfix dovecot
```

The last two steps restart email related services and show their state, so you can check if all went well. If you got troubles just remove the files from the `/etc/mailad/le/` and repeat the above steps, that will re-create a self signed certificate and put it on service.

## Software Installs

``` sh
make install
```

This step installs all needed software. Beware that we **ALWAYS** purge the soft and old configs in this step. In this way we always start with a fresh set of files for the provision stage. If you have a non clean environment the script will suggest steps to make it clean.

## Services Provision

After the software install you must provision the configuration, that is accomplished with a single command:

``` sh
make provision
```

This stage will copy the template files in the var folder of this repo replacing the values with the ones in your `mailad.conf` file. If any problem is found you will be warned about it and will need to re-run the command `make provision` to continue. There is also a `make force-provision` target in case you need to force the provision by hand.

When you reach a success message after the provision you are ready to test your new mail server, congrats!

## Reconfiguring

There must be some time in the future when you need to change some MailAD configuration parameter without reinstalling/upgrading the server. The make target `force-provision` was created for that, change the parameter(s) you want in your config file (`/etc/mailad/mailad.conf`), go to the MailAD repo folder (`/root/mailad` by default) and run:

``` sh
make force-provision
```

You will see as it makes a backup of all the config and then reinstalls the whole server with the new parameters _(this process will last about 8 minutes on up to date hardware)_. That's okay as it's the way it's developed. Take a peek on the last part of the install process, you will see a something like this:

```
[...]
===> Latest backup is: /var/backups/mailad/20200912_033525.tar.gz
===> Extracting custom files from the backup...
etc/postfix/aliases/alias_virtuales
etc/postfix/rules/body_checks
etc/postfix/rules/header_checks
etc/postfix/rules/lista_negra
[...]
```

Yes, the `force-provision` as well as the `upgrade` make targets preserve the user modified data.

If you need to reset some of those files to the defaults just erase them from the filesystem and make a force-provision, as simple as that.

For changes generated by upgrades to MailAD see painless upgrades in the [Features.md](Features.md#painless-upgrades) file)

## Upgrading

Eventually there will be a new version and you will want to upgrade for new features or just bug fixes, to force an upgrade just do this:

``` sh
cd /root/mailad # cd to the folder where you cloned the repository
git checkout master
git pull --rebase
make upgrade
```

That's it just follow the instructions... If you just upgrade to be up to date, you are done.

If you upgraded to get a new feature, then go to the `/etc/mailad/mailad.conf` file and take a peek for the options you need to enable. Yes, new features will be disabled by default to not break your current setup.

Once you enabled/configured the options, go to the cloned folder [/root/mailad in this example] and run a reconfig:

``` sh
cd /root/mailad # cd to the folder where you cloned the repository
make force-provision
```

You are done.

## Now What?

There is a [FAQ](FAQ.md) file to search for common problems; or you can reach me via Telegram under my nickname: [@pavelmc](https://t.me/pavelmc)
