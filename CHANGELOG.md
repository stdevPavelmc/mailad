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