# Active Directory Requirements For This Tool

As was mentioned earlier, this tool requires that you has administrative access over a correctly configured Active Directory (AD) server.

_**NOTICE:** Since the end of February 2021 the AD property fields used by MailAD were simplified. If you have a server running configs pre-Feb'2021, please take a peek at [Simplify_AD_config.md](Simplify_AD_config.md) to know how to migrate to the new simplified setup._

**Note:** We encourage the use of Samba as an AD domain controller.

## LDAPS for securing your LDAP communications

If you use Samba 4 you can use Secure LDAP (LDAPS), you just need to specify `SECURELDAP=yes` in the `/etc/mailad/mailad.conf` file when configuring the provision.

If you need or want to run it in plain text you need to make a change in the Samba configuration (from version 4.x it has it's defaults to LDAPS, aka: plain LDAP is disabled), to enable plain LDAP locate the [global] section on your's `/etc/samba/smb.conf` file and add this to the end of the section. Please note that you must avoid using plain LDAP in any scenario: use LDAPS instead.

``` sh
[global]
    ... your configs ...

    # talk to Linux boxes in an insecure way (only in restricted network segments e.g. DMZ)
    ldap server require strong auth = no

```

If you use a Windows AD server then by default you need to use plain LDAP (no security); to enable LDAPS you need to read the section [Optional encryption for LDAP communications](Features.md#optional-encryption-for-LDAP-communications) in the Features.md file to know how to enable it

## RSAT (Remote Server Administration Toolkit)

To handle user adminstration we recommend the installation of the RSAT tools in a Windows pc. Samba tools are available for the Linux shell but it's hard for newcomers. If you'd like that approach, the command is `samba-tool` and has all the options you need, but that matter is not covered here.

## Linux - AD Link

To link the Linux mail server to the AD we use a regular user, not an admin. The default details for this user are shown below:

- User name: `linux`.
- Password: `Passw0rd---` _**Warning**: `(This is the default password, you must change it!)`_.
- The `linux` user should be located on the default AD tree folder `Users`, not in the corporate Organizational Unit (OU) see picture below.

![linux user image](imgs/sample_ad_listing_linux_user.png)

## Active Directory Configuration

The AD must be organized in a way that you have a main OU that contains all the users in the domain, in this example this OU is called `CO7WT` and inside it you can create the organization's structure that best suits your needs. In my case the user "Pavel" belong to the OU "Informática" (see picture below).

You need to declare at least one user for administrative purposes during the setup stage, in the picture below we can see a sample of it.

![admin use details](imgs/admin_user_details.png)

Only one detail is required, the user's E-mail field ("Correo electrónico" in Spanish). For a user to be active in the mailserver you only need this:

- User enabled and not locked in the AD.
- E-mail property set and matching the email domanin you are configuring.
- Optionally a user-specific quota can be set for the user in the "Web Page" field ("Página Web" in Spanish, see the Features file for more details).

## User configuration

The user configuration is done just like the admin user, a user placed inside the base OU tree $ an email property set.

In the past (before february 2020) we have another schema for user's configuration, if you came from a setup dated prior to that date **you need** to read this: [Simplify AD config](Simplify_AD_config.md)