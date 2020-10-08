# Mailad FAQ

This page is also available in the following languages: [ [Español](i18n/FAQ.es.md) 🇪🇸 🇨🇺]

Here you can find the most frequently asked questions, this file will grow with the feedback from the users.

## Installation related

- [I have installed by the instruction in the INSTALL.md file, I can check and send the mails, but they don't reach the users inbox?](FAQ.md#i-have-installed-by-the-instruction-in-the-installmd-file-i-can-check-and-send-the-mails-but-they-dont-reach-the-users-inbox)
- [I'm using Debian buster and can send emails but can't check emails via IMAPS/POP3S?](FAQ.md#im-using-debian-buster-and-can-send-emails-but-cant-check-emails-via-imapspop3s)
- [Why MailAD refuses to install ClamAV and/or SpamAssassin claiming some DNS problem?](FAQ.md#why-mailad-refuses-to-install-clamav-andor-spamassassin-claiming-some-dns-problem)
- [What ports I need to get open to make sure the servers works OK?](FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok)

## Usage related

- [All works fine with some email clients, but other fails with errors related to SSL and cyphers](FAQ.md#all-works-fine-with-some-email-clients-but-other-fails-with-errors-related-to-ssl-and-cyphers)
- [The server refuses to accept or relay emails from the users on port 25](FAQ.md#the-server-refuses-to-accept-or-relay-emails-from-the-users-on-port-25)

**============================== ANSWERS =========================**

## I have installed by the instruction in the INSTALL.md file, I can check and send the mails, but they don't reach the users inbox?

That's usually related to amavisd-new filtering not working, if you check in the logs `/var/log/mail.logs` you may see some lines like this:

```
[...] postfix/smtp[1354]: [...] to=<user@domain.tld>, [...] status=deferred (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused)
```

If you run a `mailq` command you may see something like this:

```
[...] amavis@cdomain.tld (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused) [...]
```

That usually due to amavis not working because spammassasin or clamav are set but not configured (that must happens in the provision stage...)

### Things to check:

- If you are behind a proxy get sure you configured the host, port, username and password in the `/etc/mailad/mailad.conf` file, if that is not set, do it and force a re-provision (`make force-provision` in the repository folder)
- Maybe spamassassin failed on the first rule compilation in the provision stage (slow internet?), run this as root: `sa-update` until it works with no complain, then restart amavisd-new

That must do it

## I'm using Debian buster and can send emails but can't check emails via IMAPS/POP3S?

Taking a closer look at the mail log you will see some errors in the mail log related to dovecot not starting properly, by chance you are running the OS over a LXC CT?

There is a known bug of dovecot running over a unprivileged CT that produces this errors in the log file:

```
[...] Failed at step NAMESPACE spawning /usr/sbin/dovecot: Permission denied
```

The most common is to enable nesting for that CT:

- Check the options/features for the CT.
- Enable nesting.
- Restart the CT.

Check now, it will work.

## Why MailAD refuses to install ClamAV and/or SpamAssassin claiming some DNS problem?

There is a simple fact behind that: both (SpamAssassin & ClamAV) uses a DNS query to a specific TXT record to get his database fingerprint details.

If you don't have a working DNS it will work some time after the provision and in 12-48 hours one of them will refuse to work, then Amavis will die and all your mail (going in or out the domain) will get caught in the postfix queue to amavis for 4 hours, then users will start to see MAILER-DAEMON notifications and you will get in trouble...

To avoid that, we have place a failsafe in the check stage of the install: if you enable the AV or the SA filtering on the config file, then we will check if we can get the respective DB updates via DNS, if not then you see the errors.

## What ports I need to get open to make sure the servers works OK?

This question is asked some times in the context of Firewalls & DMZ, the answer is easy:

### Incoming traffic

- Port  25/TCP (SMTP) from the outside work or from a Mail Gateway.
- Port 465/TCP (STMPTS) from the users network for legacy clients, not recommended in favor of the below one.
- Port 587/TCP (SUBMISSION) from the users network to send emails.
- Port 993/TCP (IMAPS) preffered way for the users to check and download the emails.
- Port 995/TCP (POP3S) legacy of port 993, working but dicouraged.

### Outgoing traffic

- Port  53/UDP/TCP (DNS) to query for servers to deliver mails, and also for updates of the AV and SPAM databases (if enabled)
- Ports 80/TCP and 443/TCP (HTTP/HTTPS) to get updates of the AV & SPAMD (if enabled) and to update the OS.
- Ports 25/TCP to send emails to the outside world.

Please note that in the incoming traffic no user's traffic is allowed in port 25, DO NOT allows the users to use the port 25 to send emails, this port is reserved to receive the incoming traffic from the outside world.

## All works fine with some email clients, but other fails with errors related to SSL and cyphers?

That's mainly an outdated mail client or a legacy OS, you will get this errors in Windows from XP to early Win10 versions and Microsoft clients; some other email clients as thunderbird or evolution can give this errors if they are very old (3 years or more).

Problem: MailAD has some cyphers options disabled, that ones are known to cause troubles, you can learn about that searching for terms like "SSL FREAK attack", "POODLE attack", SSL attacks, etc.

Solutions:

- Upgrade your mail client, this usually fix it.
- If you are using Microsoft Windows and Outlook mail client the fix is a little more trickier:
    - Download [IISCrypto](https://www.nartac.com/Products/IISCrypto).
    - Install it and run it.
    - Chose the option named "Best practices" then "Apply".
    - Reboot your computer.

## The server refuses to accept or relay emails from the users on port 25?

That port is reserved to receive emails from the outside world, the users can't use it to send emails, please check [this other question](FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) to know more.
