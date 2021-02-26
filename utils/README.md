# Utils for MailAD

This folder has some own & user contributed utilities to help in the setup, upgrade and general maintenance of MailAD see the index to jump to the desired one:

* [Upgrade to the simplified AD configuration](README.md#upgrade-to-the-simplified-ad-configuration)

## Upgrade to the simplified AD configuration

There are three ways of doing it:

- Samba 4 server, use the provided bash script (see below)
- Windows server, by hand for now, we need a PS superstar that craft a script to migrate the users.
- Manually, only if a small enterprise with a low mailbox count.

But first the usual warnings; to update the data in the LDAP directory to the new simplified setting you need to know this:

- If you are in a virtualized environment please do backups of the mailserver and the Samba 4 domain controller **before** the migration. So if you manage to get in a unstable state, just go back to the last backup to be safe.
- Emails flowing in or out the server in the migration process may fail, so it's advised to do the migration in a time of low email flow-rate, if that is no possible here there is a few tricks:
    - If you use a Mail gateway just stop it to avoid the mail traffic flow during the migration.
    - If you have a firewall between the server and the users (local or remote) just disable the rules to allow the mail to flow during the test.
- The Samba 4 service must be running and we will not stop it during the property updating process for the users, so the Active directory feature is not disturbed in any way.

### Samba 4

[upgrade_simple_ad.sh](upgrade_simple_ad.sh) is the script, follow the steps.

0. Get sure your DC has a repository configured and do a `apt update && apt upgrade`
0. Copy the upgrade_simple_ad.sh script to your samba AD server, no matter the path (you home or /root is fine
0. Make it executable `chmod +x upgrade_simple_ad.sh`
0. Run it as root (sudo) and pass the correct parameters (or just run it and follow the instructions)
    - "-d" the domain name.
    - "-o" the name of the OU that hold the users in the root of the Directory (just the name)
0. It will then cycle trough the user list and will migrate the properties one by one

For example, for a "test.mailad.cu" domain and a "ou" named TEST:

```sh
pavel@test:~/mailad/utils$ sudo ./upgrade_simple_ad.sh -d test.mailad.cu -o TEST
===> Parsing 'user1test' data...
 ==> User needs migration
  => Deleting old properties
  => Change quota to HomePage

[...]
```

If you see any error just note the username and go trough the RSAT interface to fix any setting for that user. I have already tested this on more than one live server with 300+ users and it worked flawlessly.

### Windows AD

No script/software you must do it by hand, see next section

### Manually

It's simple but tedious, the task below explained for a simple user, cycle on the rest and repeat the steps:

- Open the user's property window
- Clear the "Office" property.
- Clear the "Telephone number" property (please note the string on it).
- Set the "Home Page" property to the value that was in the "Telephone number".
- Save the changes.
- Repeat for the next user.
