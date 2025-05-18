# MailAD v1.2.0

[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen?style=flat-square)](https://t.me/MailAD_dev) [![Twitter Follow](https://img.shields.io/twitter/follow/co7wt?label=Follow&style=flat-square)](https://twitter.com/co7wt) [![GitHub Issues](https://img.shields.io/github/issues/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues) [![GitHub Issues Closed](https://img.shields.io/github/issues-closed/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues?q=is%3Aissue+is%3Aclosed) [![GitHub repo size](https://img.shields.io/github/repo-size/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/archive/master.zip) [![GitHub last commit](https://img.shields.io/github/last-commit/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![GitHub commit rate](https://img.shields.io/github/commit-activity/m/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![Financial contributors](https://opencollective.com/mailad/tiers/badge.svg)](https://opencollective.com/mailad)

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-11-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

![MailAD Logo](./logos/MailAD-logo-full_white_background.png)

This page is also available in the following languages: [ [Español](i18n/README.es.md) 🇪🇸 🇨🇺] [ [Deutsch](i18n/README.de.md) 🇩🇪] *Warning: translations may be outdated.*

This is a handy tool to provision a mail server on Linux linked to an Active Directory (AD from now on) server (Samba or Windows) with some constraints in mind. This is a typical mail configuration to be used in Cuba as regulated by law and security enforcement requirements, but can be used on any domain. You can see a simple provision in [this asciinema movie](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8).

## Notice

We have also some derived projects you might find interesting:

- [MailAD-Docker](https://github.com/stdevPavelmc/mailad-docker/) - A Docker Compose version of this software.
- [MailD](https://github.com/stdevPavelmc/maild/) - A multi-domain Docker solution with no AD linking, an all-web solution.
- [MailAD ansible role](https://github.com/stdevPavelmc/mailad-ansible-role) - An Ansible role for the mail server.

## Rationale

This repository is intended to be cloned on your fresh OS install under `/root` (you can use a LXC instance, VM, etc.) and setup via a main configuration file as per the file comments. Then run the steps in a makefile and follow the instructions to configure your server.

After a few steps, you will have a mail server up and running in about 15 minutes tops. *(This time is based on a 2Mbps internet connection to a repository. If you have a local repository, it will be less.)*

The recommended OS selection is as follows:

| OS | Active Support | Legacy |
|:--- |:---:|:---:|
| Ubuntu Noble 24.04 LTS | ✅ |  |
| Debian Bookworm 12 | ✅ |  |
| Ubuntu Jammy 22.04 LTS |  | ⚠️ |
| Debian Bullseye 11 |  | ⚠️ |
| Ubuntu Focal 20.04 LTS |  | ⚠️ |
| Debian Buster 10 |  | ⚠️ |
| Ubuntu Bionic 18.04 LTS |  | ⚠️ |

Legacy means it works but is not supported anymore. It's recommended to use the latest version.

***Note:** If you are using Debian Buster or Bullseye in a LXC Container (Proxmox for example), you need to tweak the Dovecot installation or it will not work. See [this fix](https://serverfault.com/questions/976250/dovecot-lxc-apparmor-denied-buster) for more information.*

It's recommended that the instance of MailAD sits within your DMZ segment with a firewall between it and your users, and a mail gateway like [Proxmox Mail Gateway](https://www.proxmox.com/en/proxmox-mail-gateway) between it and the external network.

## Features

This will provision a mail server for an enterprise serving corporate users. You can see the major features in the [Features.md](Features.md) file. Among others, you will find:

1. Low resource footprint.
2. Advanced (and optional) mail filtering features that include attachments, SPF, AntiVirus & Spam.
3. Encrypted LDAP communication as an option.
4. In-place protection against major and known SSL & mail service attacks.
5. Automatic alias using AD groups.
6. Manual alias, manual ban, manual headers & body checks.
7. On-demand backup and restore of raw configurations.
8. Really painless upgrades.
9. Daily mail traffic summary to your inbox.
10. Optional user privilege access via AD groups (local/national/international).
11. Optional disclaimer/notice/warning on every outgoing mail.
12. Optional aggressive SPAM fight measures.
13. Weekly background check for new versions with a detailed email if you need to upgrade.
14. Optional mailbox split by office/city/country.
15. Optional Webmail, you have Roundcube or SnappyMail to choose from.

## TODO

There is a [TODO list](TODO.md), which serves as a kind of "roadmap" for new features. But as I (the only dev so far) have a life, a family, and a daily job, you know...

All development is made on weekends or late at night (seriously, take a peek at the commit dates!). If you need a feature or fix ASAP, please consider making a donation or contacting me, and I will be happy to help you ASAP. My contact info is at the bottom of this page.

## Constraints and requirements

Do you remember the comment at the top of the page about *"...with some constraints in mind..."*? Yeah, here they are:

1. Your user base and configuration come from AD as mentioned. We prefer Samba AD, but it works on Windows too; see [the AD requirements for this tool](AD_Requirements.md).
2. The username part of the email must not exceed 20 characters, so `thisisalongemailaddress@domain.com` will be truncated to `thisisalongemailaddr@domain.com`. This is not our rule, but a limitation of the LDAP directory as specified by Windows Schema.
3. The mail storage will be a folder in `/home/vmail`. All mail will belong to a user named `vmail` with uid:5000 & gid:5000. Tip: that folder can be a NFS mount or any other type of network storage (configurable).
4. You use a Windows PC to control and manage the domain (must be a domain member and have the RSAT installed and activated). We recommend Windows 10 LTSC/Professional.
5. The communication with the server is done in this way: (See [this question](FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) on the FAQ file to know more)
    - Port 25 (SMTP) is used to receive incoming traffic from the outside world or from a mail gateway.
    - Port 587 (SUBMISSION) is used to receive emails from the users to be delivered locally or relayed to other servers.
    - Port 465 (SMTPS) is used like port 587 but is only enabled as a legacy option; its use is discouraged in favor of port 587.
    - Port 993 (IMAPS) the preferred method to retrieve email from the server.
    - Port 995 (POP3S) used like 993, but discouraged in favor of IMAPS (unless you are on a very slow link).

## How to install or try it?

We have an [INSTALL.md](INSTALL.md) file just for that, and also a [FAQ](FAQ.md) file with common problems.

## This is free software!

Have a comment, question, contribution, or fix?

Use the Issues tab in the repository URL or drop me a message via [Twitter](https://twitter.com/co7wt) or [Telegram](https://t.me/pavelmc).

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/danny920825"><img src="https://avatars2.githubusercontent.com/u/33090194?v=4?s=100" width="100px;" alt="danny920825"/><br /><sub><b>danny920825</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=danny920825" title="Tests">⚠️</a> <a href="#ideas-danny920825" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/HugoFlorentino"><img src="https://avatars0.githubusercontent.com/u/11479345?v=4?s=100" width="100px;" alt="HugoFlorentino"/><br /><sub><b>HugoFlorentino</b></sub></a><br /><a href="#ideas-HugoFlorentino" title="Ideas, Planning, & Feedback">🤔</a> <a href="#example-HugoFlorentino" title="Examples">💡</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.sysadminsdecuba.com"><img src="https://avatars1.githubusercontent.com/u/12705691?v=4?s=100" width="100px;" alt="Armando Felipe"/><br /><sub><b>Armando Felipe</b></sub></a><br /><a href="#ideas-armandofcom" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Koratsuki"><img src="https://avatars0.githubusercontent.com/u/20727446?v=4?s=100" width="100px;" alt="Koratsuki"/><br /><sub><b>Koratsuki</b></sub></a><br /><a href="#ideas-Koratsuki" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=Koratsuki" title="Code">💻</a> <a href="#translation-Koratsuki" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://www.daxslab.com"><img src="https://avatars0.githubusercontent.com/u/13596248?v=4?s=100" width="100px;" alt="Gabriel A. López López"/><br /><sub><b>Gabriel A. López López</b></sub></a><br /><a href="#translation-glpzzz" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/oneohthree"><img src="https://avatars0.githubusercontent.com/u/7398832?v=4?s=100" width="100px;" alt="oneohthree"/><br /><sub><b>oneohthree</b></sub></a><br /><a href="#ideas-oneohthree" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://iskra.ml"><img src="https://avatars3.githubusercontent.com/u/6555851?v=4?s=100" width="100px;" alt="Eddy Ernesto del Valle Pino"/><br /><sub><b>Eddy Ernesto del Valle Pino</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=edelvalle" title="Documentation">📖</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dienteperro"><img src="https://avatars.githubusercontent.com/u/5240140?v=4?s=100" width="100px;" alt="dienteperro"/><br /><sub><b>dienteperro</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=dienteperro" title="Documentation">📖</a> <a href="#financial-dienteperro" title="Financial">💵</a> <a href="#ideas-dienteperro" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://jjrweb.byethost8.com/"><img src="https://avatars.githubusercontent.com/u/11667019?v=4?s=100" width="100px;" alt="Joe1962"/><br /><sub><b>Joe1962</b></sub></a><br /><a href="#ideas-Joe1962" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=Joe1962" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sandy-cmg"><img src="https://avatars.githubusercontent.com/u/101523070?v=4?s=100" width="100px;" alt="Sandy Napoles Umpierre"/><br /><sub><b>Sandy Napoles Umpierre</b></sub></a><br /><a href="#ideas-sandy-cmg" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=sandy-cmg" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://cz9dev.github.io/"><img src="https://avatars.githubusercontent.com/u/97544746?v=4?s=100" width="100px;" alt="Carlos Zaldívar"/><br /><sub><b>Carlos Zaldívar</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=cz9dev" title="Code">💻</a> <a href="#translation-cz9dev" title="Translation">🌍</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=cz9dev" title="Tests">⚠️</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file if you want to contribute to MailAD to know the details of how to do it. All kinds of contributions are welcomed: ideas, fixes, bug reports, improvements, and even a phone top-up to keep me online.

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

