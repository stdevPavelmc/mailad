# Simpler Active Directory Users Configuration

Since the end of February 2021 the fields required for MailAD configuration in the AD were reduced. Now only one field is required and you have the option to input a user-specific quota:

- E-mail: **[Mandatory]** The user's email address
- Web Page: **[Optional]** The user's **specific** mailbox quota

![admin use details new](imgs/admin_user_details.png)

## What is the process to migrate to this simplified schema if I have an old MailAD version already?

To migrate you need to read the [related explanation](utils/README.md#upgrade-to-the-simplified-ad-configuration) in the utils' README file, and follow the steps there.

## Why the quota is optional?

Simple, the general per user's quota is set now in the `/etc/mailad/mailad.conf` file as a variable named `DEFAULT_MAILBOX_SIZE` and it's set by default at 200 MB, see the section named [General and individual quota system](Features.md#general-and-individual-quota-system) in the Features.md file for more details.

## Why You Changed?

- Simplicity: Practice has revealed that humans are prone to typos or missing fields.
- Productivity: Think in 300 users: how many time will take to set 4 fields vs just 1 field on those 300 users?
- User's advice: Some users was using the fields in the old schema for things on their setups, and that will rule out MailAD as a viable option.

## Reference of previous fields

Previously you had to setup four properties for a single user, a tedious task if you has many users, the properties were these:

- E-mail: The user's email address
- Office: The general mail storage folder
- Telephone: The user's mailbox quota
- Web Page: The name for the particular user's mailbox within the general mail storager folder followed by an explicit forward slash "/")

![admin use details old](imgs/admin_user_details_old.png)