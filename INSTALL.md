# MailAD installation instructions

## Introduction & checks

To avoid permission problems we recommend you to held the files under the `/root` directory, so from this moment and forward you need to be root to runs the following commands, `sudo -i` is your friend if you are not root.

If you are behind a proxy remember you can use use apt over it to update, upgrade and install the needed apps. Just export the following variables and all traffic will be routed to the outside, here you have an example:

``` sh
export http_proxy="http://user:password@proxy.enterprise.cu:3128/"
export https_proxy="http://user:password@proxy.enterprise.cu:3128/"
```

You need to setup a proxy also for git tor work, just do this (If not done already):

``` sh
echo "[http]" >> ~/.gitconfig
echo "    proxy = http://user:password@proxy.enterprise.cu:3128/" >> ~/.gitconfig
```

If your setup use a proxy without username and password authentication just omit the "user:password@" part in the lines above

## Initial setup

Just update and upgrade your system, install two dependencies and clone this repository under `/root`, like this:

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

## Prepare your server

To prepare your server to install you need to first create the default config, just run this command:

``` sh
make conf
```

This step will create the folder /etc/mailad and place a default mailad.conf file on it, now you are ready yo start

## Initial config

Read and fill all needed variables on the `/etc/mailad/mailad.conf` file, please read carefully and choose wisely!

_At this point the fast & furious ones can just run `make all` and follow the clues, the rest of the mortals just follow the next steps_

## Dependencies handling

Call the dependencies to install all the needed tools, like this

``` sh
make deps
```

This will install a group of needed tools to run the provision scripts, if all goes well no error must be shown; if an error is shown then you must work it out as it will be 99% of the time a problem related to the repository link and update

## Checks

Once you have installed the dependencies it's time to check the local config for errors

``` sh
make conf-check
```

This will check for some of the pre-defined scenarios and configs, if any problem is found you will be warned about

### Most common pitfalls

- Hostname: your PC need to know your full qualified hostname see [this tutorial](https://gridscale.io/en/community/tutorials/hostname-fqdn-ubuntu/) to know how to solve that issue
- ldapsearch errors: 100% of the time is due to a typo on the mailad.conf file, check it carefully

We are ready to install now, Oh wait! We need to generate the SSL certificates first.

## Certificate creation

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

## Software installs

``` sh
make install
```

This step installs all the needed softwares, be ware that we **ALWAYS** purge the soft and old configs in this step; in this way we always start with a fresh set of files for the provision stage. If you have a non clean environment the script will suggest steps to make it clean

## Services provision

After the software install you must provision the configuration, that's accomplished with a single command:


``` sh
make provision
```

This stage will copy the template files in the var folder of this repo replacing the values with the ones in your `mailad.conf` file. If any problem is found you will be warned about it and will need to re-run the command `make provision` to continue. There is also a `make force-provision` target in case you need to force the provision by hand

When you reach a success message after the provision you are ready to test your new mail server, congrats!
