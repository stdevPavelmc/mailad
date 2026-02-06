# MailAD Codebase Guide for AI Agents

## Project Overview
MailAD is a bash-based mail server provisioning tool that links to Active Directory (Samba/Windows) for user management. It automates multi-service mail infrastructure deployment on Debian/Ubuntu systems. The project targets Cuba's specific regulatory requirements but is usable anywhere.

**Key services provisioned:** Postfix (SMTP), Dovecot (IMAP/POP3), Amavis (AV filtering), SpamAssassin, optional Roundcube/SnappyMail webmail, Nginx frontend.

## Architecture Pattern: Template-Based Provisioning

The core workflow uses **template files + variable substitution**:
1. **Template files** in `var/` directories (e.g., `var/postfix/main.cf`, `var/dovecot-2.2/dovecot.conf`) contain placeholders like `_DOMAIN_`, `_ADMINMAIL_`, `_MESSAGESIZE_`
2. **Configuration** comes from two sources:
   - `common.conf`: system-wide defaults (OS support matrix, package lists, service names, version detection)
   - `mailad.conf`: user-facing deployment config (domain, hostname, LDAP credentials, feature toggles)
3. **Provisioning** (see [scripts/provision.sh](scripts/provision.sh#L85-L96)): `sed` replaces placeholders with values, then copies templated configs to `/etc/`
4. **Version handling**: Dovecot configs differ by version (2.2/2.3/2.4 in `var/dovecot-*/`)—detection happens in provision.sh

## Critical Developer Workflows

### Building/Deploying
```bash
make conf           # Interactive config setup
make deps           # Install build dependencies
make conf-check     # Validate AD connectivity + config
make install        # Install packages (no configuration)
make provision      # Apply configurations to /etc/ + start services
make all            # Full sequence: deps → conf-check → install → provision
```

### Testing
- **Manual tests:** [tests/test.sh](tests/test.sh) runs SMTP/auth validation against a live server
- **Test dependencies:** `.mailadmin.auth` file required (credentials for admin + national/local test users)
- **Key test scenarios:** receive emails, auth for users, reject open relay, size limits, restriction levels

### Configuration Upgrade Pattern
- `scripts/confupgrade.sh` runs before provision to detect and apply config migrations
- Backward compatibility is maintained by detecting old config keys and transforming them

## Project Conventions & Patterns

### Variable Naming in Configs
- **User-facing** (in `mailad.conf`): `DOMAIN`, `HOSTNAME`, `ADMINMAIL`, `MESSAGESIZE`, feature flags like `DOVECOT_SPAM_FILTER_ENABLED`
- **System** (in `common.conf`): `SERVICENAMES` (array of systemd services), `OS_SUPPORTED`/`OS_LEGACY`/`OS_DISCONTINUED` (OS matrices), `VARS` (dynamically extracted from `mailad.conf`)
- **Escaped versions**: `ESCDOMAIN`, `ESCNATIONAL` for sed patterns (backslash escaping dots/special chars)

### Postfix Rules & LDAP Integration
- **LDAP bind:** Configured in [var/postfix/ldap/](var/postfix/ldap/) with separate files for lookup tables (domains, users, groups)
- **Mail restrictions:** Domain-local vs. national/international users controlled via `ESCNATIONAL` regex in `filter_loc` and `filter_nat` files
- **Alias management:** [scripts/groups.sh](scripts/groups.sh) runs daily (cron) to sync AD groups as email aliases

### Dovecot LDAP & Sieve
- **LDAP auth:** Dovecot config points to AD via [var/dovecot-*/dovecot-ldap.conf.ext](var/dovecot-2.2/dovecot-ldap.conf.ext)
- **Mailbox quotas:** Per-user sizes from AD `wWWHomePage` field, defaults to `DEFAULT_MAILBOX_SIZE`
- **Sieve filtering:** Auto-creates spam filter if `DOVECOT_SPAM_FILTER_ENABLED` is set

### Amavis/AV Integration
- **Config location:** [var/amavis/conf.d/](var/amavis/conf.d/) with modular structure (e.g., `50-user` for customization)
- **Feature toggles:** `ANTIVIRUS`, `SPAMD_PROXY` enable ClamAV and SpamAssassin via sed substitution (comment/uncomment pattern)
- **Spam bypass:** [scripts/provision.sh](scripts/provision.sh#L350-L394) conditionally enables `@bypass_spam_checks_maps`

### Backup/Restore
- [scripts/backup.sh](scripts/backup.sh), [scripts/restore.sh](scripts/restore.sh), [scripts/custom_restore.sh](scripts/custom_restore.sh) preserve `/etc/` configurations
- No user mailbox data included—focus is config portability

## Git & Issue Workflow
- **Branch naming:** `{username}_t{issue#}_{short_description}` (e.g., `stdevPavelmc_t228_fix_cron`)
- **Commits:** Start with `Refs #{issue#}` to auto-link to GitHub issues
- **Pull requests:** Mention @stdevPavelmc when ready to merge; CI/CD (GitHub Actions) validates against test suite

## Key Integration Points
- **Active Directory:** All user management via LDAP bind DN (configurable, typically Domain Admin)
- **DNS:** Checked by [scripts/check_dns_records.sh](scripts/check_dns_records.sh) for MX/SPF/DKIM readiness
- **Mail storage:** `/home/vmail/` (uid:gid 5000:5000)—can be NFS mount
- **Webmail:** Roundcube or SnappyMail with SQLite/MySQL backend, installed via [scripts/webmails.sh](scripts/webmails.sh)

## When Adding Features
1. Add toggle in `mailad.conf` (e.g., `NEW_FEATURE_ENABLED`)
2. Add corresponding template files or sed edits in `scripts/provision.sh`
3. Version-gate if affecting Postfix/Dovecot (query `common.conf` OS/version arrays)
4. Update [tests/test.sh](tests/test.sh) to validate new feature
5. Document in [README.md](README.md) and [Features.md](Features.md)
