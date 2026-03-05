# MailAD Scripts Documentation

This directory contains all the shell scripts used by MailAD for configuration, environment testig, installation and maintenance of the mail server system. This script are not designed to be ran as standalone [most of them] as they are called from the Makefile script or are scheduled via cron jobs.

*WARNING:* This info may be outdated, it's more like a guideline.

## Script Dependencies and Execution Order

### Pre configuration and env testing
Scripts to test the environment and dependencies

- **`deps.sh`** - Installs system dependencies and packages required for MailAD
- **`conf.sh`** - Creates default configuration files in `/etc/mailad/`
- **`gen_cert.sh`** - Check and generates SSL/TLS certificates (self-signed or uses Let's Encrypt) if needed
- **`vmail_create.sh`** - Creates the vmail user and sets up mail storage permissions
- **`test_localhost.sh`** - Validates local system configuration and prerequisites
- **`test_bind_dn.sh`** - Tests Active Directory connectivity and authentication
- **`test_mailadmin.sh`** - Validates mail administrator account configuration

### Core Installation Scripts
These scripts form the backbone of the MailAD installation and provisioning process:

- **`install_mail.sh`** - Installs mail server packages (Postfix, Dovecot, Amavisd-new, etc.)
- **`provision.sh`** - Main configuration script that sets up all services and applies configurations
- **`confupgrade.sh`** - Upgrades configuration files when MailAD version changes
- **`feedback.sh`** - Sends anonymous usage statistics to developers
- **`install_purge.sh`** - Completely removes MailAD and all related packages

### Webmails related
Scripts for ongoing system management and configuration:

- **`webmails.sh`** - Installs and configures webmail applications (RoundCube/SnappyMail)
- **`roundcube.sh`** - Installs and configures RoundCube webmail
- **`snappy.sh`** - Installs and configures SnappyMail webmail

### Backup and Recovery Scripts
Scripts for data protection and system recovery:

- **`backup.sh`** - Creates backups of all configuration files and certificates
- **`restore.sh`** - Restores from available backup files
- **`custom_restore.sh`** - Selective restoration of user-modified configuration files
- **`clamav_handle.sh`** - Manages ClamAV database backups and restoration

### Testing, Validation and periodic Scripts
Scripts for system testing and validation, some are programed as periodic tasks via cron:

- **`groups.sh`** - Manages mail groups and aliases from Active Directory, create alias for groups
- **`resume.sh`** - Generates daily mail traffic summaries
- **`check_maildirs.sh`** - Monitors and manages orphaned mail directories
- **`check_new_version.sh`** - Checks for new MailAD versions and notifies administrators
- **`cert_weekly_check.sh`** - Monitors SSL certificate expiration
- **`check_dns_records.sh`** - Validates DNS configuration for mail delivery

## Key Dependencies

### System Requirements
- **Operating Systems**: Ubuntu 22.04/24.04, Debian 11/12
- **Shell**: Bash (required for all scripts)
- **Package Manager**: APT (Debian/Ubuntu package management)

### Core Dependencies
- **LDAP Tools**: `ldap-utils` for Active Directory integration
- **Mail Services**: `postfix`, `dovecot-core`, `amavisd-new`
- **Security**: `clamav`, `spamassassin` (optional)
- **Web Server**: `nginx`, `php-fpm` (for webmail)

### Optional Dependencies
- **Webmail**: `roundcube` or `SnappyMail` packages
- **Monitoring**: `pflogsumm` for mail log analysis
- **Testing**: `swaks` for email testing

## Configuration Files

### Main Configuration
- **`/etc/mailad/mailad.conf`** - Primary MailAD configuration
- **`common.conf`** - Shared configuration variables

### Service Configurations
- **`/etc/postfix/`** - Postfix mail server configuration
- **`/etc/dovecot/`** - Dovecot IMAP/POP3 server configuration
- **`/etc/amavis/`** - Amavisd-new content filtering configuration
- **`/etc/clamav/`** - ClamAV antivirus configuration

## Automation and Scheduling

### Cron Jobs
Several scripts are automatically scheduled via cron:

- **`groups.sh`** - Daily execution for group synchronization
- **`resume.sh`** - Daily execution for mail traffic summaries
- **`check_maildirs.sh`** - Monthly execution for mail directory cleanup
- **`check_new_version.sh`** - Weekly execution for version checking
- **`cert_weekly_check.sh`** - Weekly execution for certificate monitoring
