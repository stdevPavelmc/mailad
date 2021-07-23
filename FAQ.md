# MailAD FAQ

This page is also available in the following languages: [ [Español](i18n/FAQ.es.md) 🇪🇸 🇨🇺]

Here you can find the most Frequently Asked Questions, this file will grow with the users feedback.

## QUESTIONS

## Installation Related

- [I have installed following the instructions in INSTALL.md file, I can check and send emails, but they don't reach the users inbox](FAQ.md#i-have-installed-following-the-instructions-in-installmd-file-i-can-check-and-send-emails-but-they-dont-reach-the-users-inbox)
- [I'm using Debian buster and can send emails but can't check emails via IMAPS/POP3S?](FAQ.md#im-using-debian-buster-and-can-send-emails-but-cant-check-emails-via-imapspop3s)
- [Why MailAD refuses to install ClamAV and/or SpamAssassin claiming some DNS problem?](FAQ.md#why-mailad-refuses-to-install-clamav-andor-spamassassin-claiming-some-dns-problem)
- [What ports I need to get open to make sure the servers works OK?](FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok)

## Usage Related

- [All works fine with some email clients, but other fails with errors related to SSL and cyphers](FAQ.md#all-works-fine-with-some-email-clients-but-other-fails-with-errors-related-to-ssl-and-cyphers)
- [The server refuses to accept or relay emails from the users on port 25](FAQ.md#the-server-refuses-to-accept-or-relay-emails-from-the-users-on-port-25)

## ANSWERS

## I have installed following the instructions in INSTALL.md file, I can check and send emails, but they don't reach the users inbox

That's usually related to amavisd-new filtering not working, if you check in the logs `/var/log/mail.log` you may see some lines like this:

```
[...] postfix/smtp[1354]: [...] to=<user@domain.tld>, [...] status=deferred (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused)
```

If you run a `mailq` command you may see something like this:

```
[...] amavis@cdomain.tld (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused) [...]
```

That's usually due to amavis not working because spammassasin or clamav are set but not configured (that could happened in the provision stage...)

### Things to check:

- If you are behind a proxy get sure you configured the host, port, username and password in the `/etc/mailad/mailad.conf` file, if that is not set, do it and force a re-provision (`make force-provision` in the repository folder).
- Maybe spamassassin failed on the first rule compilation in the provision stage (slow internet?), run this as root: `sa-update` until it works with no complain, then restart amavisd-new.

That must do it

## I'm using Debian buster and can send emails but can't check emails via IMAPS/POP3S?

Taking a closer look at the mail log you will see some errors in the mail log related to dovecot not starting properly. Probably is running in a LXC container?

There is a known bug of dovecot running in an unprivileged container that produces this errors in the log file:

```
[...] Failed at step NAMESPACE spawning /usr/sbin/dovecot: Permission denied
```

The most common solution is to enable nesting for that container:

- Check the options/features for the container.
- Enable nesting.
- Restart the container.

Check now, it will work.

## Why MailAD refuses to install ClamAV and/or SpamAssassin claiming some DNS problem?

There is a simple fact behind that: both (SpamAssassin & ClamAV) uses a DNS query to a specific TXT record to get his database fingerprint details.

If you don't have a working DNS it will work some time after the provision and in 12-48 hours one of them will refuse to work, then Amavis will die and all your mail (going in or out the domain) will get caught in the postfix queue to amavis for 4 hours, then users will start to see MAILER-DAEMON notifications and you will get in trouble...

To avoid that, we have place a failsafe in the check stage of the install: if you enable the ClamAV or the SpamAssassin filtering on the config file, then we will check if we can get the respective database updates via DNS, if not then you see the errors.

## What ports I need to get open to make sure the servers works OK?

Ports required:

### Incoming traffic

- Port 25/TCP (SMTP) from the external network or from a perimeter mail gateway.
- Port 465/TCP (SMTPS) from the users network for legacy clients, not recommended, preferably use Submission.
- Port 587/TCP (SUBMISSION) from the users network, preferred way for users for sending emails.
- Port 993/TCP (IMAPS) from the users network, preferred way for users for retrieving emails.
- Port 995/TCP (POP3S) from the users network, not recommended, preferably use IMAPS.

### Outgoing traffic

- Port 53/UDP/TCP (DNS) to query upstream dns servers
- Ports 80/TCP (HTTP) and 443/TCP (HTTPS) to get updates of the AV & SPAMD (if enabled) and to update the OS.
- Port 25/TCP (SMTP) to send emails to the external network.

Please note that in the incoming traffic no user traffic is allowed in port 25, DO NOT allow users to use port 25 for sending emails, this port is reserved to receive the incoming traffic from the external network.

## All works fine with some email clients, but other fails with errors related to SSL and cyphers?

That's mainly an outdated mail client or a legacy OS, you will get this errors in Windows from XP to early Win10 versions and Microsoft clients; some other email clients as Thunderbird or Evolution can give this errors if they are very old (3 years or more).

Problem: MailAD has some cyphers options disabled, that ones are known to cause problem, you can learn about that searching for terms like "SSL FREAK attack", "POODLE attack", SSL attacks, etc.

Solutions:

- Upgrade your mail client, this will usually fix the issues.
- If you are using Microsoft Windows and Outlook mail client the fix is a little more trickier:
    - Download [IISCrypto](https://www.nartac.com/Products/IISCrypto).
    - Install it and run it.
    - Chose the option named "Best practices" then "Apply".
    - Reboot your computer.

## The server refuses to accept or relay emails from the users on port 25?

That port is reserved to receive emails from the external network, users should not use it to send emails, please check [this other question](FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) to know more.
