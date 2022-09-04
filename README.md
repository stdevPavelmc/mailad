# MailAD

[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen?style=flat-square)](https://t.me/MailAD_dev) [![Twitter Follow](https://img.shields.io/twitter/follow/co7wt?label=Follow&style=flat-square)](https://twitter.com/co7wt) [![GitHub Issues](https://img.shields.io/github/issues/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues) [![GitHub Issues Closed](https://img.shields.io/github/issues-closed/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/issues?q=is%3Aissue+is%3Aclosed) [![GitHub repo size](https://img.shields.io/github/repo-size/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/archive/master.zip) [![GitHub last commit](https://img.shields.io/github/last-commit/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![GitHub commit rate](https://img.shields.io/github/commit-activity/m/stdevPavelmc/mailad?style=flat-square)](https://github.com/stdevPavelmc/mailad/commits/master) [![Financial contributors](https://opencollective.com/mailad/tiers/badge.svg)](https://opencollective.com/mailad)

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-10-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

This page is also available in the following languages: [ [Español](i18n/README.es.md) 🇪🇸 🇨🇺] [ [Deutsch](i18n/README.de.md) 🇩🇪]

This is a handy tool to provision a mail server on linux linked to an Active Directory (AD from now on) server (Samba or Windows) with some constraints in mind, as this is a typical mail config to be used in Cuba as regulated by law and security enforcement requirements. You can see a simple provision in [this asciinema movie](https://asciinema.org/a/fD1LuVLfeb8RPCHOIgbR1J9d8).

We have a docker development on going on another repository, take a peek and test it or contribute: [MailAD-Docker](https://github.com/stdevPavelmc/mailad-docker/)

## Rationale

This repository is intended to be cloned on your fresh OS install under `/root` (you can use a LXC instance, VM, etc) and setup on a main conf file as per the file comments, then run the steps on a makefile and follow the steps to configure your server.

After a few steps you will have a mail server up and running in about 15 minutes tops. _(this time is based on a 2Mbps internet connection to a repository, if you have a local repository it will be less)_

This tool is tested and supported on:

- Ubuntu Bionic 18.04 LTS (legacy).
- Ubuntu Focal 20.04 LTS (actual dev env).
- Ubuntu Jammy 22.04 LTS (experimental support, future dev env).
- Debian Buster 10 (see note below please).
- Debian Bullseye 11 (see note below please).

_**Note:** If you are using a Debian Container on LXC (Proxmox for example) you need to tweak the dovecot install or it will not work, see [this fix](https://serverfault.com/questions/976250/dovecot-lxc-apparmor-denied-buster) for more info_

It's recommended that the instance of MailAD sits within your DMZ segment with a firewall between it and your users and a mail gateway like [Proxmox Mail Gateway](https://www.proxmox.com/en/proxmox-mail-gateway) between it and the external network.

## Features

This will provision a mail server for an enterprise serving corporate users. You can see the major features in the [Features.md](Features.md) file, among others you will find:

0. Low resource footprint.
0. Advanced (and optional) mail filtering features that includes attachments, SPF, AntiVirus & Spam.
0. Encrypted LDAP communication as an option.
0. In place protection to major and known SSL & mail service attacks.
0. Automatic alias using AD groups.
0. Manual alias, manual ban, manual headers & body checks.
0. On demand backup and restore of raw configurations.
0. Really painless upgrades.
0. Daily mail traffic summary to your inbox.
0. Optional user privilege access via AD groups (local/national/international).
0. Optional disclaimer/notice/warning on every outgoing mail.
0. Optional aggressive SPAM fight measures.

## TODO

There is a [TODO list](TODO.md), which serves as a kind of "roadmap" for new features, but as I (the only dev so far) have a life, a family and a daily job, you know...

All dev is made on weekend or late at night (seriously take a peek on the commit dates!) if you need a feature or fix ASAP, please take into account making a donation or found me and I will be happy to help you ASAP, my contact info is on the bottom of this page.

## Constraints and requirements

Do you remember the comment at top of the page about _"...with some constraints in mind..."?_ Yeah, here they are:

0. Your user base and config came from AD as mentioned, we prefer Samba AD but it works on Windows too; see [the AD requirements for this tool](AD_Requirements.md)
0. The username part of the email must not pass the 20 chars mark, so `thisisalongemailaddress@domain.com` will be cut to `thisisalongemailaddr@domain.com` this is not our rule, but a handycap of the LDAP directory as specified by Windows Schema.
0. The mail storage will be a folder in `/home/vmail`, all mail will belong to a user named `vmail` with uid:5000 & gid:5000. Tip: that folder can be a NFS mount or any other type of network storage (configurable)
0. You use a Windows PC to control and manage the domain (must be a domain member and have the RSAT installed and activated), we recommend a Windows 10 LTSC/Professional
0. The communication with the server is done in this way: (See [this question](FAQ.md#what-ports-i-need-to-get-open-to-make-sure-the-servers-works-ok) on the FAQ file to know more)
    - Port 25 (SMTP) is used to receive incoming traffic from the outside world or from a mail gateway.
    - Port 587 (SUBMISSION) is used to receive emails from the users to be delivered locally or relayed to other servers.
    - Port 465 (SMTPS) is used like port 587 but is only enabled as a legacy option, its use is discouraged in favor of port 587.
    - Port 993 (IMAPS) the preffered method to retrieve the email form the server.
    - Port 995 (POP3S) used like the 993, but discouraged in favor of IMAPS (unless you are in a very slow link)

## How to install or try it?

We have a [INSTALL.md](INSTALL.md) file just for that, and also a [FAQ](FAQ.md) file with common problems.

## This is free software!

Have a comment, question, contributions or fix?

Use the Issues tab in the repository URL or drop me a message via [Twitter](https://twitter.com/co7wt) or [Telegram](https://t.me/pavelmc)

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/danny920825"><img src="https://avatars2.githubusercontent.com/u/33090194?v=4?s=100" width="100px;" alt=""/><br /><sub><b>danny920825</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=danny920825" title="Tests">⚠️</a> <a href="#ideas-danny920825" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/HugoFlorentino"><img src="https://avatars0.githubusercontent.com/u/11479345?v=4?s=100" width="100px;" alt=""/><br /><sub><b>HugoFlorentino</b></sub></a><br /><a href="#ideas-HugoFlorentino" title="Ideas, Planning, & Feedback">🤔</a> <a href="#example-HugoFlorentino" title="Examples">💡</a></td>
    <td align="center"><a href="https://www.sysadminsdecuba.com"><img src="https://avatars1.githubusercontent.com/u/12705691?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Armando Felipe</b></sub></a><br /><a href="#ideas-armandofcom" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/Koratsuki"><img src="https://avatars0.githubusercontent.com/u/20727446?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Koratsuki</b></sub></a><br /><a href="#ideas-Koratsuki" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=Koratsuki" title="Code">💻</a> <a href="#translation-Koratsuki" title="Translation">🌍</a></td>
    <td align="center"><a href="http://www.daxslab.com"><img src="https://avatars0.githubusercontent.com/u/13596248?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Gabriel A. López López</b></sub></a><br /><a href="#translation-glpzzz" title="Translation">🌍</a></td>
    <td align="center"><a href="https://github.com/oneohthree"><img src="https://avatars0.githubusercontent.com/u/7398832?v=4?s=100" width="100px;" alt=""/><br /><sub><b>oneohthree</b></sub></a><br /><a href="#ideas-oneohthree" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://iskra.ml"><img src="https://avatars3.githubusercontent.com/u/6555851?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Eddy Ernesto del Valle Pino</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=edelvalle" title="Documentation">📖</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/dienteperro"><img src="https://avatars.githubusercontent.com/u/5240140?v=4?s=100" width="100px;" alt=""/><br /><sub><b>dienteperro</b></sub></a><br /><a href="https://github.com/stdevPavelmc/mailad/commits?author=dienteperro" title="Documentation">📖</a> <a href="#financial-dienteperro" title="Financial">💵</a> <a href="#ideas-dienteperro" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://jjrweb.byethost8.com/"><img src="https://avatars.githubusercontent.com/u/11667019?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Joe1962</b></sub></a><br /><a href="#ideas-Joe1962" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=Joe1962" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/sandy-cmg"><img src="https://avatars.githubusercontent.com/u/101523070?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sandy Napoles Umpierre</b></sub></a><br /><a href="#ideas-sandy-cmg" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/stdevPavelmc/mailad/commits?author=sandy-cmg" title="Tests">⚠️</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file if you want to contribute to MailAD to know the details of how to do it. All kinds of contributions are welcomed, ideas, fixes, bugs, improvements and even a phone top-up to keep me online.

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
