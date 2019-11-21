# Active Directory requirements for this tool

As we mentioned earlier, this tools trust you has a well configured active directory server and has admin access to it.

## Samba

We encourage the use of Samba software, the internet is full of good tutorials about how to use samba as an AD controller.

Just a note, for efficiency sake we don't use LDAPs (or secure ldap) querys as this server and the AD one are intended to be located on a DMZ rpotected from the users and in that scenario the use of LDAPs is just a waste in time & CPU cycles.

Samba from the version 4.x has **disabled** the unsecure LDAP access, to enable please locate the [global] section and add this to the end if it

```
[global]
    ... your configs ...

    # to allow to talk with the linux boxes in an insecure way
    ldap server require strong auth = no

```

## RSAT (Remote Server Administration Toolkit)

To handle the user's adminstration we recomend to use a windows PC witth the RSAT tools installed. Sure you can use the Command Line interface in linux to handle that, the command is `samba-tool` and has all the options you need, but we will not cover that item here (yet)

## Linux - AD link

To link the Linux mail server wit the AD we use a simple user (not an admin!) the default details for this user are show below:

- User name: `linux`
- Password: `Passw0rd!!!` Warning: `(This is the default you must change it!)`
- User must be located on the `Users` default AD tree, NOT in the organizational OU see picture below

![linux user image](imgs/sample_ad_listing_linux_user.png)

## Active Directory configuration

The active directory must be organized in a way that you have a main OU that contains all the users in the domain, in this example this OU is called `MAILAD` and inside it you can create the arganization's structure that suits your needs. In my case the user "pavel" belong to the sub OU "Nodo" (see picture below)

You need to declare at least ONE user for admin purposes at the setup stage, in the picture below we can see a sample of it.

![admin use details](imgs/admin_user_details.png)

Please see how there are some fields that has content beyon the normal logic, that fieldsare used as placeholders for general and particular information about the users mail properties, lets examine them in detail:

- **Office**: this is the root of the folder that has the mail for all the users, it must match the `VMAILSTORAGE` parameter in the `mailad.conf` file
- **Telephone number**: this is the user's mail quota, expressed in kilo (K), mega (M), giga(G) or tera(T) bytes.
    - You need to set a value here, pick a dafault value and set it for all users on this field, then adjust it as practice dictates; 100M (100 Mbytes) is a good starting point
- **E-mail**: this is the user's email, if you don't set it the users is masked for the mail server, aka it does not has a email configured
- **Web page**: this is a folder name for the user, usually the user's name on the Domain controller.
    - It must be not contain spaces in any case
    - It must end with an explicit "/"
    - it can match or not the user's name part in the email, for example my user's name on the domain is pavel, but my email tends to be pavelmc and that's possible
