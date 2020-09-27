# MailAD features explained

This is a long page, so here is an index:

* [Low resource footprint](Features.md#low-resource-footprint)
* [Security protection against well known SSL & mail attacks](Features.md#security-protection-against-well-known-SSL-and-mail-attacks)
* [Active directory integration and management](Features.md#active-directory-integration-and-management)
* [Daily mail traffic summary](Features.md#daily-mail-traffic-summary)
* [Data from deleted users is handled with extreme care](Features.md#data-from-deleted-users-is-handled-with-extreme-care)
* [Let's Encrypt certificates Support](Features.md#lets-encrypt-certificates-support)
* [Automatic alias using AD groups](Features.md#automatic-alias-using-ad-groups)
* [Enforced quota control](Features.md#enforced-quota-control)
* [Dovecot filtering](Features.md#dovecot-filtering-sieve)
* [Advanced mail filtering: extensions, mime types and optionals AV, SPAM and SPF](Features.md#advanced-mail-filtering-extensions-mime-types-and-optionals-av-spam-and-spf)
* [Centralized mail storage](Features.md#centralized-mail-storage)
* [Optional encryption for LDAP communications](Features.md#optional-encryption-for-LDAP-communications)
* [Optional notifications to groups instead of only the mail admin](Features.md#optional-notifications-to-groups-instead-of-only-the-mail-admin)
* [Optional disclaimer on every outgoing mail](Features.md#optional-disclaimer-on-every-outgoing-mail)
* [Optional everyone list with custom address](Features.md#optional-everyone-list-with-custom-address)
* [Optional user privilege access via AD groups](Features.md#optional-user-privilege-access-via-ad-groups)
* [Manual alias to handle typos or enterprise positions](Features.md#manual-alias-to-handle-typos-or-enterprise-positions)
* [Manual ban list for troublesome address](Features.md#manual-ban-list-for-troublesome-address)
* [Manual headers and body checks lists](Features.md#manual-headers-and-body-checks-lists)
* [Test suite](Features.md#test-suite)
* [Raw backup and restore options](Features.md#raw-backup-and-restore-options)
* [Painless upgrades](Features.md#painless-upgrades)

## Low resource footprint

This solution is working on about 5 sites on production (to my knowledge) and minimum requirements with all features on are this:

- RAM memory: 2GB
- CPU cores: 2
- HDD space: 2GB free (no mail storage space included, as it depends on your needs)

The most demanding feature is the SPAM & AV filtering, without that we can downgrade to 1GB of RAM easily; nevertheless the actual hardware requierements depends on your mail work load and must be adjusted on the spot.

If you are willing please share some statistics and hardware details with me to update this section (hardware setup, features on, daily/monthly mail flux, etc).

[Return to index](Features.md#mailad-features-explained)

## Security protection against well known SSL and mail attacks

- Well known SSL/TLS vulnerabilities like LOGJAM, SSL FREAK, POODLE, etc are covered.
- Postfix and Dovecot known vulnerabilities are covered too.
- Built using best security practices.
- We will keep it updated against emerging threats: 
  - Fix for a recent spammer trick: forgery of the From/Return-Path to make the users think the mails are legitimate when they are not.
  - Ban (reject) of subject-less emails, a common spammer trick

Backed up by the collective knowledge of the [SysAdminsdeCuba](https://t.me/sysadmincuba) SysAdmins community.

[Return to index](Features.md#mailad-features-explained)

## Active directory integration and management

This script is intended to provision a corporative mail server inside a DMZ & behind a Mail Gateway solution (I use Proxmox Mail Gateway on the latest version)

The user base details are grabbed from a Windows Active Directory server (I recommend Samba 4 in linux, but works with a Windows server too) so user management and control is delegated to the interface you use to control de Active directory, no other service is needed, ZERO touching the mail server to make & apply some changes related to users.

For a Windows sysadmin this will be easy, just config and deploy on the mail server, then control the users in the AD interface in your PC via RSAT, see the details on the file [AD_Requirements.md](AD_Requirements.md).

If you are a Linux user then you can use `samba-tool` to control the users properties in the CLI or put a Windows VM with RSAT tools in your server with remote access to manage the domain users.

[Return to index](Features.md#mailad-features-explained)

## Daily mail traffic summary

The account configured as the mail administrator _(or the ones associated to the SYSADMINS group, if specified)_ will receive a daily summary of yesterday's mail traffic; the resume is built with the pflogsumm tool.

[Return to index](Features.md#mailad-features-explained)

## Data from deleted users is handled with extreme care

In most mailservers when you remove a user from the user's list his mail storage (maildir in our case) is automatically erased. In our case we choose to act with more caution: the user's maildir will not be deleted at once.

We will left the user's maildir intact for you to review or recover a business-critical email from a big boss to that user if this is the case. Yes, all sysadmins had been in this situation, a "ultra big boss" needs a mail from that erased mailbox, ouch!

You can recover the mail by re-creating the user account in the AD and login with the credentials.

Each month you will receive a mail from your mail server notifying you about left behind maildirs, you are free to take action about them (usually making a backup and then erase the offending maildir is enough)

Here we play a trick:

- Maildirs for deleted users between 0 to 10 months (actually 9.7) will be notified to take action.
- Maildirs for deleted users between 10 to 11.999 months will be warned about imminent removal.
- Maildirs for deleted users older than 365 days (1 year) will be removed and you will receive the removal notification.

Well no quite, the first time you will not get the maildirs removed, you will be notified about the maildirs that _will be_ erased and the way to activate that feature.

To activate that option you need to set the option `MAILDIRREMOVAL="yes"` in the config file `/etc/mailad/mailad.conf` _(you don't have that option? it's time to upgrade... see [Painless upgrades](Features.md#painless-upgrades))_ and then reprovision the server with this command:

``` sh
make force-provision
```

We think that a year is time enough to recover something from that mailbox; also that date has a legal implication: in some scenarios you are required to maintain a copy of all users digital footprint for at least one year.

Here you can see an notification sample from the first implementation of this feature:

![Picture of an email notifying left behind maildirs](imgs/check_maildirs_sample.png)

[Return to index](Features.md#mailad-features-explained)

## Let's Encrypt certificates support

You can now use a Let's Encrypt certificate out of the box, just read the section [Certificate creation](INSTALL.md#certificate-creation) in the INSTALL.md file for details.

[Return to index](Features.md#mailad-features-explained)

## Automatic alias using AD groups

Suppose you have a group of specialist that need to receive all the emails for a service, a normal example are the bills, boucher, account status notifications from a bank institution, having an alias "banking@omain.tld" that points to all of them is a neat trick.

You can configure that from the AD interface, just create a Organizational Group in the AD, make all user recipients as members of that group and set an email for the group, that's all! well, not quite.

The group checking is triggered daily around ~6:00 am, if you need to trigger it now, just run the script on `/etc/cron.daily/mail_groups_update` and that will force the update. As a cron job it will report any fail or warning to the declared mail administrator.

The trigger for this feature is the setting of a email for a group, once you set an email to a group you are triggering it next morning, Be aware that this feature can be exploited by malicious users as the alias created has no user control, anybody can send to the alias address, so use it wisely.

**Bonus:** This aliases behave not like a real distribution list (like mailman's list for example), all the generated messages have no trace of being "from" a list, and seems just like single messages from the original sender, also all answers (make it a reply or a forwards email) will have the original sender as recipient and not the list address.

**Tip:** The users must belong to a group directly for this feature to work properly, you can't create a group whish members are other groups, that does not work.

**Warning:** it's up to you to check that you don't assign a list a email address that is previously assigned in the `virtual_aliases` file or from a real users, if you fall on this one you will have delivery problems.

[Return to index](Features.md#mailad-features-explained)

## Enforced quota control

Yes, this is not optional, when you setup an user to use the email services as we discussed in the file [AD_Requirements.md](AD_Requirements.md) you must specify a size for the mailbox a good value to start is 100 MB; but finally it depends on your available space and user's behavior.

You can use any of the following letter multiplier to specify that:

- K: Kilo bytes, available but not practical as it's very small for example 900 Kbytes will be specified as "900K".
- M: Mega bytes, most used unit, for example "100M" or "2048M" for a 2GB size, but...
- G: Giga bytes, 1024M = 1G.
- T: Tera byte, this is used by heavy lifters.

**Tip:** You need to avoid using decimal units, dovecot quota is picky about that, instead of using "1.5G" use "1500M".

For example this are equivalent:

- 2048K = 2M.
- 4096M = 4G.
- 1024G = 1T.

[Return to index](Features.md#mailad-features-explained)

## Dovecot filtering (sieve)

Dovecot filtering is supported since June 2020, you can handle local filters in your webmail or even with your Mail software if you use IMAP _(don't use POP, it's not recommended for a full mail experience)_

Please note that if you uses a webmail solution then you need to configure the sieve filtering for that particular webmail. How to configure the filtering support _(also called sieve filtering or just seive)_ support is out of the scope of this tutorial, but note that it will be TLS protected, so keep that in mind when configuring it.

In the config file `mailad.conf` there is a setting that enables the global SPAM filter, when enabled if a mail is flagged by a filter as SPAM the filter will deliver the message but to the Spam/Junk folder instead of the Inbox.

If you have clients that use POP don't use this feature as SPAM tagged mails will be delivered but not shown when receiving emails, move them to use IMAP instead.

With this feature your users will have the choice to re-route emails to their personal emails while on a business trip, create a "vacation auto-response" or simply parse an classify their emails in the webmail.

[Return to index](Features.md#mailad-features-explained)

## Advanced mail filtering: extensions, mime types and optionals AV, SPAM and SPF

Advanced mail filtering is handled by Amavisd-new, that bring us the default filter by extensions and mime-types, by default most dangerous extensions and mime-types are baned, but you can tweak it to suffice your needs.

**Note:** The file to change that is `/etc/amavis/conf.d/20-debian_defaults` and be aware that if you made modifications to this file **it will not me preserved on an upgrade**

### Optional Antivirus protection

By default we setup ClamAV as the default AV solutions, if you are in Cuba you need to keep the option `USE_AV_ALTERNATE_MIRROR=yes` as the official updates of ClamAV are served via Cloudflare service and that services are banned from Cuba because the Embargo/Blockade of USA to our country.

The AV activation will not be instantaneous, as it needs to update the AV database (about 300MB) and that can take some time on busy or slow networks; a background job is set to check for AV database update every hour _(will generate a follow up mail to the mail admin or the sysadmins group)_ and a final mail notice upon activation.

The AV filtering is made optional and it's default value is set to "no" (disabled) as it will need further configuration for your to activate it fully, to do so you must configure:

- The PC must have access to a DNS server that can reach the internet.
- Allow the PC to get internet access (in your firewall or a configured proxy, keep reading)

If you are behind a proxy you must setup the proxy as per the configs in the `/etc/mailad/mailad.conf` file.

**Beware!**: If your DNS is restricted to the local or enterprise network it will not work: you will recieve a notice about it.

The ClamAV updates are linked to a TXT DNS register, if the server can't fetch the content of that register there will no updates available and the system will crash between 24 to 72 hours after the fail.

### Optional SPAM protection

By default we pass all mails by SpamAssasin a trusted spam detection utility, but you can disable it if you like, see the config in the `mailad.conf` file.

SpamAssassin will process and keep tracks of the mails but to squeeze the bet performance of it you must allow it to get updates from the internet, for that you need:

- The PC must have access to a DNS server that can reach the internet.
- Allow the PC to get internet access (in your firewall or a configured proxy, keep reading)

If you are behind a proxy you must setup the proxy as per the configs in the `mailad.conf` file.

**Beware!**: If your DNS is restricted to the local or enterprise network it will not work: you will recieve a notice about it.

The SpamAssasin updates are linked to a TXT DNS register, if the server can't fetch the content of that register there will no updates available and the system will crash between 24 to 72 hours after the fail.

### Optional SPF filtering

The Sender Policy Framework is a nice way to check for bad incoming mails, but it's only useful in a scenario where you server is internet facing, aka: no mail gateway or smart host in between.

If your mail server is behind a mail gateway or in general not internet facing it's recommended to disable the SPF filtering as it can generate more troubles than solutions.

For that reason it's shipped with that option disabled by default. If you activate it be sure to have a working DNS in the PC or it will not be able to process the queries.

[Return to index](Features.md#mailad-features-explained)

## Centralized mail storage

If you are using a virtualization solution you can configure the local mail storage as a network share and have all email in a safe storage on the network, generating clean & slim backups of the server.

**Notice**: Please make it work first on a local folder and then map the folder to a network storage, this will avoid a few headaches. If you use NFS be aware of the user id mapping need to work between the email client and the NFS server.

[Return to index](Features.md#mailad-features-explained)

## Optional encryption for LDAP communications

By default the MailAD provision script will use plain text LDAP communications, but you can switch to secure (encrypted) communications if you like. The instructions are different based on the Active Directory software you are using, let's see.

### Samba 4 AD

If you start with a fresh Samba 4 install and you have not integrated any other service you can set the `SECURELDAP=yes` option in the `/etc/mailad/mailad.conf` config file and go ahead, it will work out of the box.

If you has a previous samba4 server with other LDAP services integrated using plain text communicattions then you need to stick to use plain text ldap for compatibility.

See the [AD_Requirements.md](AD_Requirements.md) file for more details on how to enable plain text LDAP in samba.

### Windows Server AD

Well, for windows it's a bit more complicated: you need to enable the secure protocols for the LDAP service in windows, [this article from Microsoft](https://support.microsoft.com/en-us/help/321051/how-to-enable-ldap-over-ssl-with-a-third-party-certification-authority) is the starting point of the process; once done and tested that LDAP has secure protocols in place (with the test described in the mentioned article).

When done just swith `SECURELDAP=yes` in the config and run a `make force-provision` to activate the configuration.

[Return to index](Features.md#mailad-features-explained)

## Optional notifications to groups instead of only the mail admin

Some times in a enterprise you have a group of sysadmins or a group of tech people that need to receive the notifications and daily email usage resumes about the mail server, by default MailAD will deliver such notifications only to the mail admin declared in the `/etc/mailad/mailad.conf` file.

From August 2020 you have the option to declare a group to get all notifications, seek for the option `SYSADMINS` in the `/etc/mailad/mailad.conf` config file, if you don't have it, that means that it's time for an upgrade, see [Painless upgrades](Features.md#painless-upgrades) for that.

In that variable you must declare a group alias email, you can create the group by two ways, one via text files in the mail server [by the old unix method](Features.md#manual-alias-to-handle-typos-or-enterprise-positions) or by the [group mails feature](Features.md#automatic-alias-using-ad-groups) in the Active directory, pick the one that make you happy.

To apply this configuration you must follow this steps:

0. Upgrade, see [Painless upgrades](Features.md#painless-upgrades)
0. Create a group alias by any of the two method mentioned above, and test it (send a email to check)
0. Fill the option `SYSADMINS` in the `/etc/mailad/mailad.conf` config file.
0. Force a re-provision via `make force-provision`.

If you fail to create the group alias or make a typo in it's name on configuration, you (mail admin) will receive a daily mail with a warning about MailAD not finding the group mentioned in the `SYSADMINS` var.

[Return to index](Features.md#mailad-features-explained)

## Optional disclaimer on every outgoing mail

Some times you needs a legal disclaimer on each autgoing mail or a simple signature, or even a footer to promote an event or even a domain name change.

Now we have that covered, of curse as an optional feature and disabled by default; all you nedd to do is this:

0. Upgrade the install as stated in the [Painless upgrades](Features.md#painless-upgrades) section _(Just the part to upgrade the config)_
0. Go to your `/etc/mailad/mailad.conf` file and change the config parameter like this `ENABLE_DISCLAIMER="yes"`.
0. Finish the upgrade to setup all the parts in place via `make upgrade`.
0. Now you have a file like this: `/etc/mailad/disclaimer.txt`, modify it as your needs.
0. If you like to add disclaimer text with images create a `/etc/mailad/disclaimer.html.txt` and fill it with yours _(more on this below)_

A typical email message contains two versions of the message, one in plain text and other in hypertext _(HTML)_ to be formatted in your email client. 

The default disclaimer file (`/etc/mailad/disclaimer.txt`) is added to all email in the plain text section; but if no HTML discaimer is specified the plain text one it's added also to the HTML part, and that can lead to bad formatting.

A hypertext disclaimer that displays well must be created by you in `/etc/mailad/disclaimer.html.txt`, with propper HTML formatting _(no html or body tags; think in the content of a div)_.

If you want to include images in the HTML disclaimer they must be embedded into the text in base64 format. The easiest way to do that is to create a message with a discalimer (images allowed) in the body of the email and send it to yourself. Upon receiving inspect the raw code of the email and you can copy the incumbent section to the disclaimer and test it.

[Return to index](Features.md#mailad-features-explained)

## Optional everyone list with custom address

You have the option to enable a everyone address that has a few cool features:

- All users of the domain can send a mail to the list, but, the list address is hidden **every time**.
- Yes, the alias address is hidden, when you send a mail to it users will receive a copy of the mail coming from you, and if they reply to the email it will return only to you, so keep the "everyone" address to you and you will be safe.
- The address will not receive emails from outside the domain (by default), to avoid external access and security implications.
- You can get external access for the list as an option, check the mailad.conf file, the variable named `EVERYONE_ALLOW_EXTERNAL_ACCESS`.

[Return to index](Features.md#mailad-features-explained)

## Optional user privilege access via AD groups

In some scenarios you are required by law (or specific enterprise restrictions) to limit a group of users to get only national service, it goes beyond in other cases and you need add even users with only local access to the domain.

This is now possible, it's a built-in feature. To activate it you just need to create a new Organizational Unit (OU) and two Groups inside it, the OU must be placed on the root of the ldap search base declared.

**Warning:** The feature is linked to the OU & Group's names, so you must preserve the name, place and casing of all, aka:  _DO NOT MOVE OR RENAME IT_

The OU must be named `MAIL_ACCESS`, inside it you must create two groups called `Local_mail` & `National_mail`.

As you may guessed at this point, any user that belongs to the `Local_mail` group will have ONLY access to emails inside the domain address, the same is true for the ones belonging to the `National_mail` group but for national access. The access is instantaneous and you need no more actions.

You can take a look at this example to see how it's structured:

![AD example](imgs/user_access.png)

[Return to index](Features.md#mailad-features-explained)

### Optional Antivirus protection

By default we setup ClamAV as the default AV solutions, if you are in Cuba you need to keep the option `USE_AV_ALTERNATE_MIRROR=yes` as the official updates of ClamAV are served via Cloudflare service and that services are banned from Cuba because the Embargo/Blockade of USA to our country.

The AV activation will not be instantaneous, as it needs to update the AV database (about 300MB) and that can take some time on busy or slow networks; a background job is set to check for AV database update every hour (will generate a follow up mail to the mail admin or the sysadmins group) and a final notice mail up on the activation.

The AV filtering is made optional and it's default value is set to "no" (disabled) as it will need further configuration for your to activate it fully, to do so you must configure:

- The PC must have access to a DNS server that can reach the internet.
- Allow the PC to get internet access (in your firewall or a configured proxy, keep reading)

If you are behind a proxy you must setup the proxy as per the configs in the `mailad.conf` file.

### Optional SPAM protection

By default we pass all mails by SpamAssasin a trusted spam detection utility, but you can disable it if you like, see the config in the `mailad.conf` file.

SpamAssassin will process and keep tracks of the mails but to squeeze the bet performance of it you must allow it to get updates from the internet, for that you need:

- The PC must have access to a DNS server that can reach the internet.
- Allow the PC to get internet access (in your firewall or a configured proxy, keep reading)

If you are behind a proxy you must setup the proxy as per the configs in the `mailad.conf` file.

### Optional SPF filtering

The Sender Policy Framework is a nice way to check for bad incoming mails, but it's only useful in a scenario where you server is internet facing, aka: no mail gateway or smart host.

If your mail server is behind a mail gateway or in general not internet facing it's recommended to disable the SPF filtering as it can generate more troubles than solutions.

For that reason it's shipped with that option disabled by default. If you activate it be sure to have a working DNS in the PC or it will not be able to process the queries.

[Return to index](Features.md#mailad-features-explained)

## Manual alias to handle typos or enterprise positions

Imagine you have a user whose email is velkis@domain.tld or jon@domain.tld; when that users handle verbally his emails there is a big chance that the sender use the most common names _(belkis is very common vs. velkis as non common name, john vs. jon)_ and their emails will never reach your users.

Now imagine a business card for the top positions in your enterprise, they usually set their personal emails, and that's ok, really?.

What if that person leaves the enterprise? all business opportunities are lost (even more is the person leaves in a bad way)

Now, what have this two cases in common?

Alias, I bet you can spot bouncing emails in the summaries or logs at daily basis. That "wrong" emails to "belkis" or "jhon", or to a former senior position from a big customer; what if you can change that for good?

In the first case (typos or strange/weird/un-common names) you can simply create an alias that routes the wrong address to the good address.

In the second one (Top positions business cards with personal emails) you can create an alias (or even a group of them) that points to the person real email in the position and emails will always find their way to the recipient's mailbox.

How to do that?

Just connect to the server and move to the `/etc/postfix/aliases` folder, once there edit the file `alias_virtuales` and add this lines for the typos/strange names

``` sh
belkis@domain.tld       velkis@domain.tld
john@domain.tld         jon@domain.tld
```

And this for the top positions, don't forget to convince the PR specialist about printing business cards with the aliases!

``` sh
# Director/CEO
ceo@domain.tld          ernest@@domain.tld
director@domain.tld     ernest@domain.tld
direccion@domain.tld    ernest@domain.tld

# Economy
cfo@domain.tld          lidia@domain.tld
economy@domain.tld      lidia@domain.tld
economico@domain.tld    lidia@domain.tld
economica@domain.tld    lidia@domain.tld
```

Where ernest if the CEO/Director & lidia are the CFO/Economy head, if one of them changes just change the real address and keep the alias, and you will never lose a business opportunity ever.

You get it right? the business cards will be always right!

You will be tempted to make alias for a group, I know, that feature is described [here](Features.md#automatic-alias-using-ad-groups)

But, that's not all, postfix can't understand this text file! you need to compile it and instruct postfix to apply the changes, this commands does precisely that:

```sh
postmap /etc/postfix/aliases/alias_virtuales
postfix reload
```

Since June/2020 this hand crafted file is preserved on upgrades, you are welcomed.

[Return to index](Features.md#mailad-features-explained)

## Manual ban list for troublesome address

Yes, there is a list to put non desirable addresses, but not only addresses, you can put even users or domains, it's located on `/etc/postfix/rules/lista_negra`.

You have two options to declare an address/domain not welcomed: DROP or REJECT

- **DROP**: this is a shortcut to the trash bin, a redirection to /dev/null. It accepts the mail but trash it ride away.
- **REJECT**: Explicitly reject the email, you can even specify an reject code and text.

The file has some examples, you can check the [list of SMTP server return codes](https://en.wikipedia.org/wiki/List_of_SMTP_server_return_codes) to learn how to respond, look for the 5XX codes, 511 is recommended.

**Warning:** You need to make a `postmap lista_negra && postfix reload` every time you change the content of the file, to generate the binary code postfix need and to apply the change.

[Return to index](Features.md#mailad-features-explained)

## Manual headers and body checks lists

### Header checks

The header checks are stated in a file: `/etc/postfix/rules/header_checks`.

This file uses regular expressions to match the content, you can match phrases on the subject line of messages and so on, the file has an example up on you can build your rules.

One example for a rule is to match and reject mails from certain Mail User Agents (the software people's use to send emails) or for some version of them that are known to be deprecated and not valid.

In that file there are by now two rules to avoid spammers:

- A reject for subject-less emails
- A reject for sender/return address forgery

If you are using a MailAD dated from July/2020 please save your personal rules in that file, erase it and force a provision, that will place the newer file with the mentioned rules, then add your custom rules.

[Return to index](Features.md#mailad-features-explained)

### Body checks

The header checks are stated in a file: `/etc/postfix/rules/body_checks`.

This file uses regular expressions to match the content, you can match phrases on the body of the message. Please be aware that this will only match the text part of the message, MIME encoded messages will not match.

With some care and testing you can even filter MIME types or attachments, but the proper way of filter that content is with amavis, not here.

[Return to index](Features.md#mailad-features-explained)

## Test suite

Since June 2020 we have a basic test suite to test our fresh provisioned server and during development as a checkpoint to know that your new feature is not breaking the security or basic features, see [Testing the mail server](tests/README.md) for more details.

[Return to index](Features.md#mailad-features-explained)

## Raw backup and restore options

Raw backups?

Yes, a raw backup is a file that stores the configuration for all the services in the mail service along with SSL certificates, keys and the mailad.conf file.

To do a manual backup is simple, just move to the folder where you cloned MailAD (usually /root/mailad/ ) and just type:

``` sh
make backup
```

This will wrap up all the needed data and will place a file on the `/var/backups/mailad` with the format `YYYYMMDD_hhmmss.tar.gz`

To restore a backup yo need to switch to the MailAD folder an type on the console:

``` sh
make restore
```

And follow the options to pick one of the existent backups.

Please note that for the backup to be functional you need to have all the software in place or it will fail; that leads us to the next question:

### What if I need a backup to migrate to another server? Is that backup good for that?

There is no black magic on that, to migrate to another server you only need to this:

0. Get sure you copied, mapped or mounted the mail storage (`/home/vmail` by default).
0. Install MailAD (see [INSTALL.md](INSTALL.md) file)
0. Copy the folder /etc/mailad with all it's contents to the new server (can be saved from a backup)
0. Adjust the vars on `/etc/mailad/mailad.conf` (hostname or so, you can fetch it from any backup file)
0. Make a "force-provision" to install MailAD with the adjusted configs.

[Return to index](Features.md#mailad-features-explained)

## Painless upgrades

There will be a point on the future when we add a new cool feature and you want to use it, then you face the question: how to upgrade?

No problem, we have it covered (again), to upgrade the software you just need to follow this steps, all do you need is a internet connection on you mail server (or access to a local repository)

I assume you moved to the folder where you keep your local clone copy of the MailAD repository _(`/root/mailad` in recommended)_ to make the next steps.

0. Upgrade the new code from github with the command `git pull && git reset --hard`.
0. Make a raw backup with the command `make backup` and note the filename it shows to you (seriously: **WRITE IT DOWN on paper**)
0. Run the upgrade process with `make upgrade` and follow instructions if you hit some rock.

The above last step will make a second automatic raw backup "just in case".

**Note:** _Since August 2020 we have a procedure to upgrade your custom config file to include new features, in that case you will receive a notice about the need to check the file `/etc/mailad/mailad.conf` for new options, also check the `Changelog.md` file for news about the changes and new features._

Some times we introduce a new feature and that feature needs your attention or a specific configuration or tweak in your environment, if that's the case please complete the suggested steps or fixes and re-run the `make upgrade` command until it finish ok.

If al goes well you will be the proud owner of a MailAD instance, or not?

### GGGRRR! The upgrade failed! how I revert the failed upgrade?

Did you wroted down the backup file name on the second step from the list above right? If not scroll up to the terminal log and search for it.

Once you have identified the file, it's just to run the following command:

```sh
make restore
```

And follow the steps to select the proper backup file, I will wrote a (shortened) version of a successfull restore for you to see it:

```sh
root@mail:~/mailad# make restore
scripts/restore.sh
===> We found the following backups, pick one to restore:
    1)	20200922_172643
    2)	20200922_161622
    3)	20200922_161557
    4)	20200922_161543
    5)	20200922_161240
Pick the number of the backup file to restore, #1 is latest
any other value or simply an enter to abort 1
===> You selected the file:
     /var/backups/mailad/20200922_172643.tar.gz
===> Starting to restore the selected backup...
etc/postfix/
etc/postfix/postfix-files
etc/postfix/makedefs.out
etc/postfix/aliases/
[...DATA...]
etc/clamav/clamd.conf
etc/clamav/onupdateexecute.d/
etc/clamav/freshclam.conf
etc/clamav/virusevent.d/
etc/clamav/onerrorexecute.d/
Doing restart with dovecot...
● dovecot.service - Dovecot IMAP/POP3 email server
[...DATA...]
● postfix.service - Postfix Mail Transport Agent
[...DATA...]
● amavis.service - LSB: Starts amavisd-new mailfilter
[...DATA...]
● spamassassin.service
[...DATA...]
● clamav-daemon.service
[...DATA...]
● clamav-freshclam.service
[...DATA...]
===> Selected backup restored!
root@mail:~/mailad#

```

We have tested the process extensively and the chances of corruption or failure are very low. As usual in FLOSS I give only my word as warranty, make and keep backups before the upgrade to restore it in case of trouble.

[Return to index](Features.md#mailad-features-explained)