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

## 2020-06-26

### Changed

- Added: test suite for postfix basic security and the related documentation
- Fixed: group script, a bad structured if sentence

## 2020-06-19

### Changed

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