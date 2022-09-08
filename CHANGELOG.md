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

DO NOT FORGET to update the VERSION file.
-->

## [v1.1.7] - 2022-09-08

- Fixed: Fix the user's split mail folders for older OS versions (<= Ubuntu 20.04 & <= Debian 10)

## [v1.1.0] - 2022-09-07

- Added: You can split the users mail folders by home office or province, see Features.md for details

## [v1.0.0] - 2022-09-05

- Changed: Set Ubuntu 22.04 LTS as default develop environment.
- Added: Semantic versioning, there is a file on the root of the repository with the version number, starting from 1.0.0 and this file
- Added: Weekly check for new versions and warn the sysadmin group/user about latest changes.
- Added: After installation a weekly cron job will check for new versions and will notify the postmaster if new changes are found

## 2022-09-04

- Fixed: Bug #181, check for stalled mailboxes fails when using multiple DCs, was a not updated LDAP_URI var.
- Changed: Documentation, comment about the 20 chars max on the email username on the README.md

## 2022-03-25

- Fixed: Bug #172, gropus update script fails under Debian as no sbin on path (postmap reside on sbin), silent fix added.
- Fixed: Bug #174, Debian PATH & sbin fix for good (impact previous mentioned Bug #172)

## 2022-03-23

- Fixed: Bug #168 reopened, Debian 11 was picky with some ldap packages
- Changed: New & cleaner way to get & install the LDAP certs thanks to @dienteperro (now it does for every DC server specified)
- Changed: Related to the /sbin /usr/sbin missing on path on some debian systems, we fix it silently, no error or the user as this is a very specific and short issue (user's space problem)
- Changed: LDAP problems on the tests give more informative errors.
- Changed: Packages needed for testing before provision are now on a var on common.conf rather than hardcoded.
- Changed: Improved the purge process, in Debian the provision or force-porovision failed when dovecot-core was there before hand (dependency problems on Debian)
- Changed: Make conf now does what it says, if you try to make conf over an existing one, you will be warned, run it again to everwrite and make a backup of the old file
- Changed: In /etc/mailad/mailad.conf file, var HOSTAD will enforce using FQDN names instead of IPs, that's becouse the LDAP's SSL checking mechanism fails if the DC server is pointed by it's IP and not the full name.
- Added: FAQ entry for the above issue.

## 2022-03-16

- Fixed: Bug #168 Debian (et least on version 11) needs libldap and libldap-common as an explicit dependency

## 2022-03-09

- Fixed: Bug #151 that was not completely fixed, now it's
- Fixed: A minor error related to a harmless (but scary) broken pipe error during provision that was identified during works on 151 

## 2022-03-06

- Added: Feature #159, Debian 11 Bullseye support
- Changed: Services enable/disable routines on provision stage
- Fixed: A bug (typo) on the 'make clean' command
- Added: Checks for /sbin /usr/sbin missing on path on some debian systems
- Changed: Improved the parsing of the LDAP bind testing
- Fixed: Bug #158, groups.sh script was not updated with the new LDAP_URI autodetection of past improvements, sorry for that.
- Added: Feature #150, Now you can exclude the AV from the proxy when using a local/institutional mirror [Optional]
- Fixed: Bug: #151 test for DNS ClamAV version when using proxy fails, fixed, not testing that when a proxy is configured
- Changed: Feature: #146, daily email about groups creation will be generated only when there is a change.

## 2022-02-24

- Fixed: Bug #147: Clamav alternate mirrors list was not working anymore.
- Added: Feature request #152: support for multiple ADDC servers, look on the mailad.conf file for details.
- Changed: New way to handle the LDAP_URIS and DNS test.
- Fixed: Minor bugs found during the fixing of the feature #152, related to DNS/SOA tests.

## 2021-06-05

- Added: New donation methods: EnZona & QvaPay

## 2021-06-03

- Fixed: Bug #132, the garbage collector script was flagging all mailboxes on the vmailstorage folder as garbage, was a human error, I failed to update that script when doing the las feature.
- Fixed: Broken link on the README, fixed.

## 2021-02-26

- Changed: back-porting all the work on the master branch to fix identified bugs to get it to the new simplified AD schema.
- Changed: Doc updates to fill the new feature.
- Added: new translation template.

## 2020-12-03

- Fixed: a bug (#128) was setting the MGW in the mys ny_networks in postfix, and that lead to all mail reaching recipients, even the restricted ones by any rule, foxed that on this commit.

## 2020-11-12

- HAPPY BIRTHDAY #1 MailAD!!!
- Fixed: A bug in the mail install script, the group tweaking for clamav was in place even if the user choose not to install an AV, fixed now.

## 2020-10-26

- Fixed: The quota warnings emails (85 & 95% of the mailbox) was not being sent in Dovecot 2.3 (Ubuntu 20.04 & possibly also on Debian 10.x), was a permission problem on the script, fixed.
- Changed: The quota warning email is now full mime capable (plaintext + html versions inside) and has more info for the user (in spanish for now.)

## 2020-10-16

- Added: Now the force-provison and upgrade target preserve the clamav database upgrades. This will help a lot when you are in a slow internet link o behind a proxy server.

## 2020-10-14

- Fixed: AD groups with long names was not getting parsed on the automatic alias because ldapsearch tool was wrapping the output at 79 chars by default, added a fix to solve that; fixed.
- Fixed: Updates form ClamAV failed when using proxy, it was the http/s prefix, must be omitted when using proxy, fixed 

## 2020-10-13

- Modified: Removed the SSLv2 in the listing of forbidden protocols (even disabled) in dovecot 2.2, it's not supported in SSL library so no reason to be here. 
- Modified: Improved the parsing of the RELAY variable, to remove the ending ':port' part and the surrounding '[]' if present.

## 2020-10-12

- Modified: We effectively disabled TLSv1 & TLSv1.1 in Postfix and Dovecot as both protocols are flagged as insecure. 

## 2020-10-09

- Added: Fix to issue #107: small enterprise dovecot cache ttl to big, lower the ttl (from 1 hour to 10 minutes) and incremented the size of the cache for big enterprises (from ~5 to ~50 latest hits on cache)

## 2020-10-08

- Added: More spanish translations (tks to @glpzzz) and link them to the original files.
- Added: Include more contributors @glpzzz and @oneohthree
- Modified: Improved the README with more eye-candy badges and the asciinema recording
- Modified: Improve the contributions sections, adding more explicit funding instructions, adding a QR code for Transfermovil (Cuba only)

## 2020-10-07

- Added: Spanish and German translations of he README.

## 2020-10-04

- Fixed: Bug detected, the DNSBL was not working, I missed the activation of the postscreen engine in postfix on the provision script (dumb me, I activated it on my local env and forgot to include it on the provision script) fixed now.
- Added: New SPAM fight weapons related to the DNSBL & postscreen in postfix (see Features.md file about DNSBL)
- Added: improved the FAQs with details of port usage.
- Modified: README, re-arranged the featured features and improve the port usage in the readme

## 2020-10-01

- Added: DNSBL support and a basic config
- Fixed: Remove the hourly script that checks for AV activation if not AV is enabled, that's a cleaning trick, if you are changing settings and re-provisioning frequently it may be left behind
- Fixed: Same scenario of above, if you are on the move it can be left installed when no disclaimer is in use

## 2020-09-30

- Fixed: Bug detected, the disclaimer feature had a problem in one script with an incomplete sed statement, fixed.
- Fixed: Bug detected, altermime was not installed and the mail queue fails, added the install step (this is from the last feature or PR...)
- Fixed: Bug detected, when you use OUs with spaces in the name the alias list via AD groups failed as the parsing failed, fixed.
- Fixed: Bug detected, the emails sent via submission was not expanding the virtual_alias_maps, fixed. 

## 2020-09-26

- Changed: We modified almost all bash script extensively: unifying functions on the common.conf file, that allow us to clean the scripts and improve the overall maintenance of the code.
- Changed: Also fix some low level bugs in the bash scripts as well a comments and print string fixing.
- Changed: Re-arranged and reviewed Features.md file.
- Changed: SpamAssassin is disabled by default, as it can cause problems if there is DNS or Proxy errors; be aware that the problems will trigger between 24 to 72 hours after the install. Extra steps are needed see Features.md 
- Added: Optional disclaimer to outgoing mails from your domain.
- Changed: Disclaimer can be configurable to reach local users or not, this on all outgoing mails from the domain.

## 2020-09-23

- Changed: Some users reported that we use ping to test for the AD-DC and in his envs there is no ping between it's networks, and that makes sense, we switched to test for the specific LDAP port connectivity instead pings (thanks Danny Paula for the tip)

## 2020-09-22

- Fixed: ClamaV update repository configuration was not right (via freshclam.conf), fixed now: it includes multiple custom mirrors and improve timeouts for slow networks, and some other validations.
- Changed: The "upgrade" target is the same of a "force-provision" one, so we merge them and upgrade is just now an alias of force-provision.
- Removed: To match the above change we removed the upgrade script.
- Changed: Improved the apt repository handling on the install/purge options, a lot of little tweaks on this field.
- Changed: The conf upgrade check is not up front of any provision target
- Fixed: Backups, formerly if you (or an error) stop the provision process (targets: all/provision/force-provision/upgrade) your backup will get left behind and a new backup will be created on the next command, that new backup may be mangled and you will end with mangled or missing data. Now we have a simple mechanism to get sure it's the right backup and use only the backups of proven validity.
- Changed: Added a check to avoid non working (temporal) backups to fill the backup folder.
- Added: New target: "backup" it will make a backup of the actual state and tag it as working.
- Added: New target, please use it wisely: "purge-backups", yes it will wipe your backups.
- Added: New target: "restore" allows you to pick one of the recent backups to restore.
- Changed: Improved the Features file with the new options and updated the section on the painless upgrades
- Added: There is a optional feature; if you don't disable it will send me (author) a simple email up on provision or upgrading. You will receive a copy of the email, there is no hidden data or intentions. You could get notified about urgent fixes or very outdated setups. This is only for statistics purposes.

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