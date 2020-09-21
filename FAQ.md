# Mailad FAQ

Here you can find the most frequently asked questions, this file will grow with the feedback from the users

## Installation related

- [I have installed by the instruction in the INSTALL.md file, I can check and send the mails, but they don't reach the users inbox?](FAQ.md#i-have-installed-by-the-instruction-in-the-installmd-file-i-can-check-and-send-the-mails-but-they-dont-reach-the-users-inbox)
- [I'm using Debian buster and can send emails but can't check emails via IMAPS/POP3S?](FAQ.md#im-using-debian-buster-and-can-send-emails-but-cant-check-emails-via-imapspop3s)
- [Why MailAD refuses to install ClamAV and/or SpamAssassin claiming some DNS problem?](FAQ.md#why-mailad-refuses-to-install-clamav-andor-spamassassin-claiming-some-dns-problem)

## Usage related

- [All works fine with some email clients, but other fails with errors related to SSL and cyphers](FAQ.md#all-works-fine-with-some-email-clients-but-other-fails-with-errors-related-to-ssl-and-cyphers)

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
