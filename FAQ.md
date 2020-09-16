# Mailad FAQ

Here you can find a resume of the most frequently asked questions

## Instalation related

- [I have installed all by the INSTALL.md file, I can check and send the mails, but they don't reach the users inbox](FAQ.md#)

## Usage related

- [All works fine with some email clients, but other fails with errors related to SSL and cyphers](FAQ.md#)

### I have installed all by the INSTALL.md file instructions, I can check and send the mails, but they don't reach the user's inbox?

Aka: you can check and send mails but they are getting stuck in the middle and don't reach any user mailbox....

That's usually related to amavis filtering not working, if you check in the logs `/var/log/mail.logs` you may see some lines like this:

```
[...] postfix/smtp[1354]: [...] to=<user@domain.tld>, [...] status=deferred (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused)
```

If you run a `mailq` command you may see something like this:

```
[...] amavis@cdomain.tld (connect to 127.0.0.1[127.0.0.1]:10024: Connection refused) [...]
```

That usually due to amavis not working because spammassasin or clamav are set but not configured (that happens in the provision stage...)

#### Things to check:

- If you are behind a proxy get sure you configured the host, port, username and password in the `/etc/mailad/mailad.conf` file, if not set it and force a reprovision (`make force-provision` in the repository folder)
- Maybe spamassassin failed on the first rule compilation in the provision stage (slow internet?), run this as root: `sa-update` until it works with no complain, then restart amavisd-new and try

### All works fine with some email clients, but other fails with errors related to SSL and cyphers

This is mainly outdated mail clients of OS, you will get this errors in Windows from XP to early Win10 versions; some other email clients as thunderbird or evolution can give this errors if they are old.

Problem: MailAD has disabled some cyphers that are known to cause troubles, you can learn about that serching for terms like "SSL FREAK attack", "POODLE attack" and others

Solutions:

- Upgrade your mail client, this usualy fixit 
- If you are using Microsoft Windows and Outlook mail client the fix is a little more trickier:
    - Download [IISCrypto](https://www.nartac.com/Products/IISCrypto)
    - Install it and run it
    - Chose the option named "Best practices" then "Apply"
    - Reboot your computer
