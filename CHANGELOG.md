# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

<!--
This is a note for developers about the recommended tags to keep track of the changes:

- Added: for new features.
- Changed: for changes in existing functionality.
- Deprecated: for soon-to-be removed features.
- Removed: for now removed features.
- Fixed: for any bug fixes.
- Security: in case of vulnerabilities.

Dates must be YEAR-MONTH-DAY
-->

## 2020-09-20

- Fixed: If you had a non working DNS after 48 ours the databases for SpamAssassin (SA) will trip and SA will lock amavis and all your mail will got locked on the processing queue towards amavis. Fixed now: we test the DNS for the SA DB update check, if not the the install/upgrade/provision fails with a warning; no SA config is possible if you don; t have a working DNS
- Fixed: Make the ClamAV alternate database mirror configurable and ship some tested ones by default, some organizations with restrictive parent proxys are denying some address (IP based address mostly)

## 2020-09-17

- Fixed: The script that checks for clamav database upgrade via freshclam had a bug, it was closed in a chicken-egg dilema as freshclam reports to clamd but it's dead and can not reload. Now it reset the clamd before testing for it.
- Fixed: If you enable the AV filtering and the DNS does not works properly to resolve the TXT record of the update the provision will fail with an error and a comment about the need to fix the DNS issue or disable the AV filtering
- Changed: Every time we need to make a provision it will check if a configuration upgrade is needed, if so the user will receive a notification to take a peek on the changes and continue

## 2020-09-16

- Added: We have now a FAQ file!

## 2020-09-15

- Changed: Made the maildir removal optional and disabled by default

## 2020-09-14

- Added: new feature: we don't erase the user's maildir up on removal from the AD, we will keep it and warn the sysadmin to take actions with them, after a year the maildir is automatically erased
- Added: README.md notice about Debian Buster's dovecot & apparmor fail.

## 2020-09-11

- Add: Subject-less emails are rejected by default, thanks to Danny Paula (Telegram: @danny920825)
- Fixed: On Debian Buster the install target was failing, all was about a non existent debian package: amavisd-new-postfix. Thanks to Eduardo R. Barrera Pérez to report the bug.
- Changed: Now we split the packages to install in the common.conf file, so you can separately handle the Ubuntu ones from the Debian ones; also make the changes on each one to make it work.
- Fixed: Now the 'make force-provision' command preserver the users modified (custom) data for postfix.
- Changed: some of the scripts was moved and modified to allow better handling of backups and allow to backup & restore files from the last backup to support latest fix.
- Changed: INSTALL.md gained a new section on reconfiguring.

## 2020-09-01

- Fixed: Delayed activation for the AV in amavis failed as the script has a wrong check in an if statement, a typo from my side (that generates an annoying hourly mail and never activated the AV checking)
- Fixed: Once AV filtering kicks is the clamav-daemon can't check the files for viruses as it has no permissions, added clamav user to amavis group solve that.

## 2020-08-28

- Added: Advanced filtering of mails via Amavisd-new, potential attachments are baden by default, including mime-type detection to avoid extension changes.
- Added: Optional AV filtering using ClamAV, with a delayed activation mechanism, also a pre-configured alternate mirror for clamav if you are in Cuba.
- Added: Optional SpamAssassin filtering with automatic updates.
- Added: Headers checks to bounce emails that fake the sender or return path.
- Added: Options SPF checking.
- Changed: Features.md with updates of the new features.
- Changed: mailad.conf arranged by sections and the sections was labeled.

## 2020-08-25

- Added: Optional feature to redirect all notifications to a group instead of the mail admin

## 2020-08-22

- Added: Daily "Yesterday's mail traffic summary" in the mailbox of the mail admin declared in the mailad.conf file, built with pflogsumm
- Added: comment in the features about best security practices and collective knowledge of the sysadminsdecuba community

## 2020-08-21

- Added: Optional encryption for the LDAP communications, simple for Samba, complicated for Windows, see the Features.md file
- Added: From today the mailad.conf file has a variable to declare the version of the file, and a specific procedure to port/migrate the configs from an old file to the new one, allowing the addition of new variables and its default values, so we pre-configure new features with this tricks
- Changed: The "make upgrade" now is more consistent, upgrading to the users mailad.conf file, see above
- Removed: the Make target test-setup, this has no more use after the change to configs on /etc/mailad/mailad.conf

## 2020-08-12

- Changed: We split the Dovecot config templates, as we are dealing with two versions (2.2 & 2.3) and are options that clash, the provision script now picks the right one based on the version you has installed
- Changed: Added curl to the test-deps target install, we use it to check the user's email delivery
- Added: The test script now checks for the email on the user's mailbox (IMAPS) and will warn you if it can find the delivered emails, see tests/README.md for more details
- Fixed: In Dovecot version 2.3 there are a new stats plugins that needs specific permissions and some changed new SSL options

## 2020-08-08

- Changed: Modified the comments on the mailad.conf file about the exclusion of one or more IP form the net segment
- Changed: Improved the handling of the 'make deps' target, fixing one error and improving the detection of the OS
- Added: The everyone alias access (by default not allowed from outside the domain) is now made optional in the config

## 2020-08-06

- Changed: Improved SSL/TLS security on dovecot & postfix
- Changed: Optimized some scripts related to SSL and testing

## 2020-07-31

- Added: Support for using Let's Encrypt certificates out of the box or after a period of time, see README.md
- Fixed: Improved the install script, now it will fail on any repository or installation issue
- Changes: Moved the tech explanation to a own file: INSTALL.md

## 2020-07-29

- Changed: The configuration file is now on /etc/mailad/ in a file called mailad.conf; this change give us more freedom in a few scenarios and make testing over multiple OS/versions more easily, also improve the backups procedure
- Changed: Improved the docs to reflect the changes in the conf file
- Changed: Upgrade process, to match the recent changes
- Changed: Scripts now have the structure to support other Linux OS
- Added: Support for Ubuntu Focal 20.04 LTS, from now on this will be the default dev OS
- Added: Support for Debian Buster 10.x (Stable)
- Fixed: Removed the use of 'sudo' in the scripts, as it collides with Debian that has no sudo by default

## 2020-07-27

- Added: Users restrictions (local/national/international) based on being members of some AD groups and updated the docs
- Added: Documented the following features:
    - Ban list (lista_negra)
    - Header checks
    - Body checks
    - Quotas
    - Optional everyone list
- Changed: Postfix better organization on the conf folder, now ldap/rules/aliases have it's own folders
- Fixed: Group script:
    - Processing was not starting with a clean file and you may get duplicated groups in some scenarios, that's fixed now
    - Some groups with accent and non standard chars in the names returned in base64 encoding and the script missed that ones, that's fixed now
    - The everyone group now works only when the sender is a member of the local domain, if not then it will reject the mail for obvious reasons

## 2020-06-26

- Added: test suite for postfix basic security, also the related documentation
- Added: upgrade code and instructions (see Features.md file)
- Fixed: improvements in the feature page (navigation)
- Fixed: group script, culprit: a bad structured if sentence

## 2020-06-19

- Added: the SIEVE support in Dovecot
- Added: features.md file and link
- Fixed: automatic group alias creation cron link
- Fixed: other minor bugs and dependencies

## 2020-04-02

- Added: Creation of auto aliases based on group memberships
- Added: added a everyone capability
- Added: Warning in the README.md about usage of master branch only in production
- Changed: improved the SMTPS & AUBMISSION restrictions
- Changed: dovecot concurrency limit set to 1, to avoid collisions
- Fixed: email vs username usage in dovecot, unified to username
- Fixed: other minor bugs and typos

## 2019-11-22

- Initial release, basic working configuration

## 2019-11-12

- Work started