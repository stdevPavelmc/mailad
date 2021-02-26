# Simplify the AD configuration for the users

Since the end of February 2020 we introduced a simplified version of AD user's properties configuration schema.

Formerly you had to setup 4 properties for a single user, a tedious task if you has many users, the properties was this (for the record):

- Email: the user's emails
- Office: With the general mail storage folder
- Telephone: with the user's mailbox quota
- Web Page: The particular user's mailbox inside the general mail storage folder (must end in a explicit "/" to sing a folder)

![admin use details old](imgs/admin_user_details_old.png)

Since the last update we only need one required property and one optional, see it here:

- Email: the user's emails
- Web Page: **[Optional]** with the user's **specific** mailbox quota

![admin use details new](imgs/admin_user_details.png)

Why the quota is optional?

Simple, the general per user's quota is set now in the `/etc/mailad/mailad.conf` file as a variable named `DEFAULT_MAILBOX_SIZE` and it's set by default at 200 MB, see the section named [General and individual quota system](Features.md#general-and-individual-quota-system) in the Features.md file for more details.

## What is the process to migrate to this simplified schema if I have an old MailAD version already?

To migrate you need to read the [related explanation](utils/README.md#upgrade-to-the-simplified-ad-configuration) in the util's README file, and follow the steps there.

## Why you changed?

- Simplicity: practice has revealed that the sysadmins or the tech people are prone to make typos or miss a field and then spend a few hours chasing their tail to find the fix.
- Productivity: think in 300 users, how many time will take to set 4 fields vs fill 1 field on those 300 users?
- User's advice: Some users was using the fields in the old schema for things on their setups, and that will rule out MailAD as a viable option.
