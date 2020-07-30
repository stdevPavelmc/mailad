# MailAD features explained

This is a long page, so here is an index:

* [Low resource footprint](Features.md#low-resource-footprint)
* [Active directory integration and management](Features.md#active-directory-integration-and-management)
* [Enforced quota control](Features.md#enforced-quota-control)
* [Optional everyone list with custom address](Features.md#optional-everyone-list-with-custom-address)
* [Automatic alias using AD groups](Features.md#automatic-alias-using-ad-groups)
* [Optional user privilege access via AD groups](Features.md#optional-user-privilege-access-via-ad-groups)
* [Dovecot filtering](Features.md#dovecot-filtering-sieve)
* [Centralized mail storage](Features.md#centralized-mail-storage)
* [Manual alias to handle typos or enterprise positions](Features.md#manual-alias-to-handle-typos-or-enterprise-positions)
* [Manual ban list for trouble some address](Features.md#manual-ban-list-for-trouble-some-address)
* [Manual headers and body checks lists](Features.md#manual-headers-and-body-checks-lists)
* [Test suite](Features.md#test-suite)
* [Painless upgrades](Features.md#painless-upgrades)

## Low resource footprint

This solution is working on about 5 sites on production to my knowledge until the time I wrote this, the most active one has a traffic of about 3k emails monthly (~100 daily) and it's happily running on a Proxmox CT with 2 cores @1.8GHz, 512 MB of RAM & 64MB of swap.

If you are using it under a heavier load, please share with me the statistics and hardware details to update this section

## Active directory integration and management

This script is intended to provision a corporative mail server inside a DMZ & behind a Mail Gateway solution (I use Proxmox Mail Gateway on the latest version)

The server created will only handle the authentication, processing, routing and basic filtering of the mails, no SPAM/AV filtering is done by now [planed feature], that task is delegated [by now] to the Mail Gateway

The user base details are grabbed from a Windows Active Directory server (I recommend Samba 4 in linux, but works with a Windows server too) so user management and control is delegated to the interface you use to control de Active directory, no other service is needed, ZERO touching the mail server to make & apply some changes

For a Windows sysadmin this will be easy, just config and deploy on the mail server, then control the users in the AD interface in your PC via RSAT, see the details on the file [AD_Requirements.md](AD_Requirements.md). If you are a Linux user then you can use `samba-tool` to control the users properties in the CLI or put a Windows VM with RSAT tools in your server with remote access to manage the domain users

## Enforced quota control

Yes, this is not optional, when you setup an user to use the email services as we discussed in the file [AD_Requirements.md](AD_Requirements.md) you must specify a size for the mailbox a good value to start is from 20 to 100 MB depending on your available space and user's behavior.

You can use any of the following letter multiplier to specify that:

- K: Kilo bytes, available but not practical as it's very small for example 900 Kbytes will be specified as "900K"
- M: Mega bytes, most used unit, for example "100M" or "2048M" for a 2GB size, but...
- G: Giga bytes, 1024M = 1G
- T: Tera byte, this is used by heavy lifters

**Tip:** You need to avoid using decimal units, dovecot quota is picky about that, instead of using "1.5G" use "1500M"

For example this are equivalent:

- 2048K = 2M
- 4096M = 4G
- 1024G = 1T

## Optional everyone list with custom address

You have the option to enable a everyone address that has a few cool features:

- All users of the domain can send a mail to the list, but the list address is hidden every time
- The address is hidden, when you send a mail to it all mail users will receive a copy of the mail coming from you, and if they reply to the email it will return only to you, so keep the address to you and you will be safe
- The address will not receive emails from outside the domain, to avoid external access and security implications

## Automatic alias using AD groups

Suppose you have a group of specialist that need to receive all the emails for a service, a normal example are the bills, boucher, account status notifications from a bank institution, having an alias "banking@omain.tld" that points to all of them is a neat trick

You can configure that from the AD interface, just create a Organizational Group in the AD, make all user recipients as members of that group and set and email for the group, that's all; well not quite.

The group checking is triggered daily around ~6:00 am, if you need to trigger it now, just run the script on `/etc/cron.daily/mail_groups_update` and that will force the update. As a cron job it will report any fail or warning to the declared mail administrator

The trigger for this feature is the setting of a email for a group, once you set an email to a group you are triggering it next morning, Be aware that this feature can be exploited by malicious users as the alias created has no user control, anybody can send to the alias address, so use it wisely

**Bonus:** this aliases behave not like a real distribution list (like mailman's list for example), all the generated messages have no trace of being "from" a list, and seems just like single messages from the original sender, also all answers (make it a reply or a forwards email) will have the original sender as recipient and not the list address

**Tip:** the users must belong to a group directly for this feature to work properly, you can't create a group whish members are other groups abd expect it to work.

**Warning:** it's up to you to check that you don't assign a list a email address that is previously assigned in the `virtual_aliases` file or from a real users, if you fall on this one you will have delivery problems.

## Optional user privilege access via AD groups

In some scenarios you are required by law (or specific enterprise restrictions) to limit a group of users to get only national service, it goes beyond in other cases and you need add even users with only local access to the domain

This is now possible and optional, it's a built-in feature. To activate it you just need to create a new Organizational Unit (OU) and two Groups inside it, the OU must be placed on the root of the ldap search base declared

**Warning:** The feature is linked to the OU & Group's names, so you must preserve the name, place and casing of all, aka  _DO NOT MOVE OR RENAME IT_

The OU must be named `MAIL_ACCESS`, inside it you must create two groups called `Local_mail` & `National_mail`

As you may guessed at this point, any user that belongs to the `Local_mail` group will have ONLY access to emails inside the domain address, the same is true for the ones belonging to the `National_mail` group but for national access. The access is instantaneous and you need no more actions

You can take a look at this example:

![AD example](imgs/user_access.png)

## Dovecot filtering (sieve)

Dovecot filtering is enabled/supported since June 2020, you can handle local filters in your webmail or even with your Mail software if you use IMAP (don't use POP, it's not recommended for a full mail experience)

Please note that if you uses a webmail solution then you need to configure the sieve filtering for that particular webmail, and that is out of the scope of this.

In the config file `mailad.conf` there is a setting that enables the global SPAM filter, when enabled if a mail is flagged by a filter as SPAM the filter will deliver the message but to the Spam/Junk folder instead of the Inbox

If you have clients that use POP don't use this feature as SPAM tagged mails will be delivered but not shown when receiving emails, move them to use IMAP instead

With this feature your users will have the choice to re-route emails to their personal emails while on a business trip, create a "vacation auto-response" or simply parse an classify their emails in the webmail

## Centralized mail storage

If you are using a virtualization solution you con configure the local mail storage as a network share via the preferred method and have all email in a safe storage on the network, generating clean & slim backups of the server

A notice: please make it work first on a local folder and then map the folder to a network storage, this will avoid a few headaches debugging a fail o a problem. If you use NFS be aware of the user id mapping needed to work

## Manual alias to handle typos or enterprise positions

Imagine you have a user whose email is velkis@domain.tld or jon@domain.tld; when that users handle verbally his emails there is a big chance that the sender use the most common names (belkis vs. velkis, john vs. jon) and their emails will never reach your users

Now imagine a business card for the top positions in your enterprise, they usually set their personal emails, and that's ok, but if that person leaves the enterprise? all business opportunities are lost (even more is the person leaves in a bad way)

Now, what have this two cases in common?

Alias, I bet you can spot bouncing emails in the summaries or logs at daily basis. That "wrong" emails to "belkis" or "jhon", or to a former senior position from a big customer; what if you can change that for good?

In the first case (typos or strange/weird names) you can simply create an alias that routes the wrong address to the good address.

In the second one (Top positions business cards with personal emails) you can create an alias (or even a group of them) that points to the person real email in the position and emails will always find their way to the recipient's mailbox.

How to do that?

Just connect to the server and move to the `/etc/postfix` folder, once there edit the file `alias_virtuales` and add this lines for the typos/strange names

``` sh
belkis@domain.tld       velkis@domain.tld
john@domain.tld         jon@domain.tld
```

And this for the top positions (don't forget to convince the PR specialist about printing business cards with the aliases)

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

Where ernest if the CEO/Director & lidia are the CFO/Economy head, if one of them changes just change the real address, and you will never lose a business opportunity ever

You get it right? the business cards are always right!

You will be tempted to make alias for a group, I know, that feature is described [here](Features.md#automatic-alias-using-ad-groups)

But, that's not all, postfix can't understand this file so far! you need to compile it and instruct postfix to apply the changes, this commands does precisely that:

```sh
postmap /etc/postfix/alias_virtuales
postfix reload
```

Since June/2020 this hand crafted file is preserved on upgrades, you are welcomed

## Manual ban list for trouble some address

Yes, there is a list to put non desirable addresses, but not only addresses, you can put even users or domains, it's located on `/etc/postfix/rules/lista_negra`

You have two options to declare an address/domain not welcomed: DROP or REJECT

- DROP: this is a shortcut to the trash bin, a redirection to /dev/null. It accepts the mail but trash it ride away
- REJECT: Explicitly reject the email, you can even specify an reject code and text

The file has some examples, you can check the [list of SMTP server return codes](https://en.wikipedia.org/wiki/List_of_SMTP_server_return_codes) to learn how to respond, look for the 5XX codes, 511 is recommended

**Warning:** You need to make a `postmap lista_negra && postfix reload` every time you change the content of the file, to generate the binary code postfix need and to apply the change

## Manual headers and body checks lists

### Header checks

The header checks are stated in a file: `/etc/postfix/rules/header_checks`

This file uses regular expressions to match the content, you can match phrases on the subject line of messages and so on, the file has an example up on you can build your rules

One example for a rule is to match and reject mails from certain Mail User Agents (the software people's use to send emails) or for some version of them that are known to be deprecated and not valid

### Body checks

The header checks are stated in a file: `/etc/postfix/rules/body_checks`

This file uses regular expressions to match the content, you can match phrases on the body of the message. Please be aware that this will only match the text part of the message, MIME encoded messages will not match

With some care and testing you can even filter MIME types or attachments

## Test suite

Since June 2020 we have a basic test suite to test our fresh provisioned server and during development as a checkpoint to know that your new feature is not breaking the security or basic features, see [Testing the mail server](tests/README.md) for more details

## Painless upgrades

There will be a point on the future when we add a new cool feature and you want to use it, then you face the question: how to upgrade?

No problem, we have it covered, to upgrade the software you just need to follow this steps, all do you need is a internet connection on you mail server (or access to a local repository)

I assume you moved to the mailad folder `/root/mailad` to make the next steps

0. Upgrade the new code from github with the command `git pull && git reset --hard`
0. Run the upgrade process with `make upgrade` and follow instructions if you hit some rock

The last step will make a FULL backup of the actual software configs before try anything. No matter if the upgrade worked or failed you will end with a backup file in the folder `/var/backups/mailad/` whose name is the date and time of the `make upgrade`; so in the unlikely outcome of a broken system you can do this to restore your system state:

### how to revert a failed upgrade?

- Move to the mailad folder `/root/mailad` and run this: `install-purge && make install`
- Move to the folder `/var/backups/mailad/` and identify the backup file you want to restore, for example: "/var/backups/mailad/20200626_145845.tar.gz"
- Restore the files with this commands:

```sh
cd /
tar -zxvf /var/backups/mailad/20200626_145845.tar.gz
reboot
```

The PC will restart and all must be working as before the failed upgrade

We have tested the process extensively and the chances of corruption or failure are very low, if you hit a broken "upgrade" process feel free to contact me via Telegram, my nick there is @pavelmc

As usual in FLOSS no bonding warranty, make and keep backups before the upgrade to restore it in case of trouble
