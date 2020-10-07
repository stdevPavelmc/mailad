# Active Directory requirements for this tool

As we mentioned earlier, this tools trust you has a well configured active directory server and has admin access to it.

**Note:** We encourage the use of Samba AD, the internet is full of good tutorials about how to use samba as an AD controller

## LDAPS or securing your LDAP communications

If you use Samba 4 you can start using secure LDAP (LDAPS) from start, you just need to specify `SECURELDAP=yes` in the `/etc/mailad/mailad.conf` file when configuring the provision

If you need or want to run it in plain text you need to make a change in the Samba configuration; samba from version 4.x has in place only secure LDAP access (plain LDAP is disabled), to enable it please locate the [global] section on your's `/etc/samba/smb.conf` file and add this to the end of that section.

``` sh
[global]
    ... your configs ...

    # to allow to talk with the linux boxes in an insecure way
    ldap server require strong auth = no

```

If you use a Windows AD server then by default you need to use plain LDAP (no security) to enable LDAPS you need to read the section [Optional encryption for LDAP communications](Features.md#optional-encryption-for-LDAP-communications) in the Features.md file to know how to enable it

## RSAT (Remote Server Administration Toolkit)

To handle the user's adminstration we recommend to use a windows PC with the RSAT tools installed. Sure you can use the Command Line interface in linux to handle that but it's hard for newcommers, if you like to venture in that field the command is `samba-tool` and has all the options you need, but we will not cover that item here (yet)

## Linux - AD link

To link the Linux mail server with the AD we use a simple user (not an admin!) the default details for this user are show below:

- User name: `linux`
- Password: `Passw0rd---` _**Warning**: `(This is the default you must change it!)`_
- User must be located on the `Users` default AD tree, NOT in the organizational OU see picture below

![linux user image](imgs/sample_ad_listing_linux_user.png)

## Active Directory configuration

The active directory must be organized in a way that you have a main OU that contains all the users in the domain, in this example this OU is called `MAILAD` and inside it you can create the organization's structure that suits your needs. In my case the user "pavel" belong to the sub OU "Nodo" (see picture below)

You need to declare at least ONE user for admin purposes at the setup stage, in the picture below we can see a sample of it.

![admin use details](imgs/admin_user_details.png)

Please see how there are some fields that has content beyond the normal logic, that fields are used as placeholders for general and particular information about the users mail properties, lets examine them in detail:

- **Office**: this is the root of the folder that has the mail for all the users, it must match the `VMAILSTORAGE` parameter in the `mailad.conf` file
- **Telephone number**: this is the user's mail quota, expressed in kilo (K), Mega (M), Giga (G) or Tera (T) bytes.
  - You need to set a value here, pick a default value and set it for all users on this field, then adjust it as practice dictates; 100M (100 Mbytes) is a good starting point
- **E-mail**: this is the user's email, if you don't set it the users is masked for the mail server, aka it does not has a email configured
- **Web page**: this is a folder name for the user, usually the user's name on the Domain controller.
  - It must be not contain spaces in any case
  - It must end with an explicit "/" _(for the curious, this is the way we say this is a folder not a file)_
  - it can match or not the user's name part in the email, for example my user's name on the example domain is pavel and also the email is pavel@mailad.cu; but it can be other like pavelmc@mailad.cu or sysadmin@mailad.cu
