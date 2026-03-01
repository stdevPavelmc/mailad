# MailAD Development & Operations Guide

**Version**: v1.2.7-rc
**Last Updated**: February 2026  
**Primary Maintainer**: Pavel Milanes Costa (@stdevPavelmc)  
**License**: GPL v3

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture & Components](#architecture--components)
3. [Development Workflow](#development-workflow)
4. [Configuration Management](#configuration-management)
5. [Security & Compliance](#security--compliance)
6. [Operations & Maintenance](#operations--maintenance)
7. [Contributing Guidelines](#contributing-guidelines)
8. [Dependencies & Requirements](#dependencies--requirements)
9. [Testing Strategy](#testing-strategy)
10. [Deployment & Scaling](#deployment--scaling)
11. [Troubleshooting](#troubleshooting)

## Project Overview

### Purpose & Scope

MailAD is an automated mail server provisioning tool designed for enterprise environments, specifically targeting Cuban regulatory requirements while remaining adaptable for global use. The project provides a complete mail server solution with Active Directory integration, advanced security features, and enterprise-grade reliability.

**Key Objectives:**
- Rapid deployment of secure mail servers (15 minutes typical setup)
- Active Directory integration for user management
- Compliance with enterprise security standards
- Low resource footprint (2GB RAM minimum)
- Enterprise-grade spam/virus filtering

### Core Technologies

- **Mail Transport**: Postfix (SMTP server)
- **Mail Storage**: Dovecot (IMAP/POP3 server with virtual mailboxes)
- **Content Filtering**: Amavisd-new with SpamAssassin and ClamAV
- **Web Interface**: RoundCube or SnappyMail webmail
- **Authentication**: LDAP/Active Directory integration
- **Security**: SSL/TLS encryption, DNSBL, SPF validation

### Target Environment

- **Primary OS**: Ubuntu 24.04 LTS, Debian 12
- **Deployment**: DMZ environments behind mail gateways
- **Scale**: Enterprise deployments (tested with 300+ users)
- **Network**: Requires internet access for updates and filtering

## Architecture & Components

### System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Clients   │    │   Mail Clients   │    │  Mail Gateway   │
│ (Webmail/IMAP)  │    │ (SMTP/IMAP/POP)  │    │   (Optional)    │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          └──────────────────────┼───────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     MailAD Server       │
                    │                         │
                    │ ┌─────────┐ ┌─────────┐ │
                    │ │ Postfix │ │ Dovecot │ │
                    │ └────┬────┘ └────┬────┘ │
                    │      │           │      │
                    │ ┌────▼────┐ ┌────▼────┐ │
                    │ │Amavisd- │ │ LDAP/AD │ │
                    │ │  new    │ │  Auth   │ │
                    │ └────┬────┘ └────┬────┘ │
                    │      │           │      │
                    │ ┌────▼────┐ ┌────▼────┐ │
                    │ │SpamAss  │ │ ClamAV  │ │
                    │ │assin    │ │ (AV)    │ │
                    │ └─────────┘ └─────────┘ │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     Mail Storage        │
                    │   (/home/vmail)         │
                    │                         │
                    │ ┌─────────┐ ┌─────────┐ │
                    │ │User Mail│ │User Mail│ │
                    │ │  Box 1  │ │  Box 2  │ │
                    │ └─────────┘ └─────────┘ │
                    └─────────────────────────┘
```

### Component Breakdown

#### Core Services

1. **Postfix** - SMTP Server
   - Handles incoming/outgoing mail
   - Implements SMTP, SUBMISSION, and SMTPS protocols
   - Configured with virtual domains and LDAP lookups
   - Security features: DNSBL, SPF, pipelining restrictions

2. **Dovecot** - IMAP/POP3 Server
   - Provides mail access for clients
   - Virtual mailbox implementation
   - Sieve filtering support
   - LDAP authentication integration

3. **Amavisd-new** - Content Filter
   - Mail scanning and filtering coordination
   - Integration with SpamAssassin and ClamAV
   - Quarantine management
   - Policy enforcement

#### Security Components

1. **SpamAssassin** - Spam Detection
   - Bayesian filtering
   - DNSBL integration
   - Custom rule management
   - Automatic updates

2. **ClamAV** - Antivirus
   - Signature-based virus detection
   - Multiple mirror support (Cuba-friendly)
   - Real-time scanning
   - Database updates

3. **SSL/TLS** - Encryption
   - Certificate management
   - Let's Encrypt support
   - Strong cipher configuration
   - Perfect Forward Secrecy

#### Authentication & Directory

1. **LDAP/Active Directory**
   - User authentication
   - Group-based access control
   - Quota management
   - Secure LDAP support

2. **Webmail Integration**
   - RoundCube (repository-based)
   - SnappyMail (download-based)
   - LDAP auto-completion
   - Mobile-friendly interfaces

### Configuration Hierarchy

```
/etc/mailad/
├── mailad.conf             # Main configuration
├── insts.data              # Installation tracking
└── [backup files]          # Configuration backups

/etc/postfix/
├── main.cf                 # Postfix main config
├── master.cf               # Service definitions
├── aliases/                # Virtual alias maps
├── ldap/                   # LDAP connection configs
└── rules/                  # Filtering rules

/etc/dovecot/
├── dovecot.conf            # Main dovecot config
└── conf.d/                 # Modular configuration

/etc/amavis/
├── conf.d/                 # Amavisd-new configs
└── [templates]             # Template files

/etc/clamav/
├── clamd.conf              # ClamAV daemon config
└── freshclam.conf          # Database update config
```

## Development Workflow

### Git Workflow

MailAD follows a simplified GitFlow model with the following conventions:

#### Branch Strategy

- **`master`** - Production-ready releases
- **`develop`** - Integration branch for new features
- **`feature/*`** - Feature development branches
- **`hotfix/*`** - Emergency fixes for production

#### Commit Conventions

```bash
# Format: "Refs #issue_number, description"
Refs #123, add support for Ubuntu 24.04 LTS
Refs #456, fix DNSBL configuration bug
Refs #789, improve error handling in provision script
```

#### Release Process

1. **Feature Development**: Work on `feature/*` branches
2. **Integration**: Merge to `develop` for testing
3. **Release Preparation**: Create release branch from `develop`
4. **Testing**: Comprehensive testing on release branch
5. **Release**: Merge to `master` with version tag
6. **Deployment**: Deploy to production environments

### Development Environment Setup

Local development is done on LXC containers with isolated environments deployed via an ansible playbooks. Commands to the hosts are passed via SSH or lxc-attach/exec commands. See ./local-dev/README.md for detailed setup instructions.

#### Container Architecture

The Ansible setup creates 4 specialized containers:

| Container | OS | Purpose | IP Address | Key Services |
|-----------|----|---------|------------|--------------|
| **dc** | Ubuntu Noble | Active Directory/Samba server | 10.0.3.2 | Samba4, LDAP |
| **mailu** | Ubuntu Noble | Mail server (Ubuntu testing) | 10.0.3.3 | Postfix, Dovecot, Amavisd |
| **maild** | Debian Bookworm | Mail server (Debian testing) | 10.0.3.4 | Postfix, Dovecot, Amavisd |
| **test** | Ubuntu Noble | General-purpose testing | 10.0.3.5 | Testing tools, SSH access |

#### Comprehensive Testing Workflow

After setting up the LXC environment and configuring the domain controller, run the comprehensive test suite:

**1. Configure Test Environment:**
```bash
# Set up test credentials
cp .mailadmin.auth /root/mailad/
cp .mailad.auth /root/mailad/

# Configure test parameters
export IP=10.0.3.3  # or 10.0.3.4 for Debian
export DOMAIN=test.mailad.cu
```

**2. Run Full Test Suite:**
```bash
# Access test container
sudo lxc exec test -- bash

# Run comprehensive tests
cd /root/mailad
./tests/test.sh 10.0.3.3  # Test Ubuntu mail server
./tests/test.sh 10.0.3.4  # Test Debian mail server
```

**3. Test Components Individually:**
```bash
# Test specific components
./tests/test.sh --component=postfix
./tests/test.sh --component=dovecot
./tests/test.sh --component=webmail
```

**4. Test Authentication and Mail Flow:**
```bash
# Test LDAP authentication
./scripts/test_bind_dn.sh

# Test mail delivery
./scripts/test_localhost.sh

# Test webmail login
python3 ./tests/test_login.py
```

#### Test Coverage

The comprehensive test suite validates:

- **Mail Delivery**: SMTP, IMAP, POP3 functionality
- **Authentication**: LDAP/AD integration and user authentication
- **Security Features**: Spam filtering, virus scanning, access controls
- **Cross-Platform Compatibility**: Ubuntu vs Debian behavior
- **Network Connectivity**: Container-to-container communication
- **Configuration Validation**: All MailAD configuration options

#### Test Results and Logs

Test results are logged to:
- `/root/mailad/tests/test_transactions_results.log` - Main test results
- `/root/mailad/tests/latest.log` - Latest test run details
- Container-specific logs in `/var/log/` directories

**Review Test Results:**
```bash
# Check test results
cat /root/mailad/tests/test_transactions_results.log

# View detailed logs
cat /root/mailad/tests/latest.log

# Check container logs
sudo lxc exec mailu -- tail -f /var/log/mail.log
```

#### Comprehensive Testing Workflow

After setting up the LXC environment and configuring the domain controller, run the comprehensive test suite:

**1. Configure Test Environment:**
```bash
# Set up test credentials
cp .mailadmin.auth /root/mailad/
cp .mailad.auth /root/mailad/

# Configure test parameters
export IP=10.0.3.3  # or 10.0.3.4 for Debian
export DOMAIN=test.mailad.cu
```

**2. Run Full Test Suite:**
```bash
# Access test container
sudo lxc exec test -- bash

# Run comprehensive tests
cd /root/mailad
./tests/test.sh 10.0.3.3  # Test Ubuntu mail server
./tests/test.sh 10.0.3.4  # Test Debian mail server
```

**3. Test Components Individually:**
```bash
# Test specific components
./tests/test.sh --component=postfix
./tests/test.sh --component=dovecot
./tests/test.sh --component=webmail
```

**4. Test Authentication and Mail Flow:**
```bash
# Test LDAP authentication
./scripts/test_bind_dn.sh

# Test mail delivery
./scripts/test_localhost.sh

# Test webmail login
python3 ./tests/test_login.py
```

#### Test Coverage

The comprehensive test suite validates:

- **Mail Delivery**: SMTP, IMAP, POP3 functionality
- **Authentication**: LDAP/AD integration and user authentication
- **Security Features**: Spam filtering, virus scanning, access controls
- **Cross-Platform Compatibility**: Ubuntu vs Debian behavior
- **Network Connectivity**: Container-to-container communication
- **Configuration Validation**: All MailAD configuration options

#### Test Results and Logs

Test results are logged to:
- `/root/mailad/tests/test_transactions_results.log` - Main test results
- `/root/mailad/tests/latest.log` - Latest test run details
- Container-specific logs in `/var/log/` directories

**Review Test Results:**
```bash
# Check test results
cat /root/mailad/tests/test_transactions_results.log

# View detailed logs
cat /root/mailad/tests/latest.log

# Check container logs
sudo lxc exec mailu -- tail -f /var/log/mail.log
```

### Code Organization

#### Directory Structure

```
mailad/
├── scripts/                # Provisioning scripts
│   ├── install_mail.sh     # Main installation
│   ├── provision.sh        # Configuration deployment
│   ├── backup.sh          # Backup utilities
│   └── [other scripts]    # Specialized tools
├── tests/                 # Test suite
│   ├── test.sh            # Main test runner
│   ├── test_login.py      # Webmail testing
│   └── README.md          # Testing documentation
├── utils/                 # Utility scripts
│   ├── samba_scaffold.sh  # Test AD setup
│   └── upgrade_simple_ad.sh # Migration tools
├── var/                   # Configuration templates
│   ├── dovecot-2.2/       # Dovecot v2.2 configs
│   ├── dovecot-2.3/       # Dovecot v2.3 configs
│   ├── postfix/           # Postfix configurations
│   └── [other services]   # Service templates
└── [documentation]        # Project documentation
```

#### Script Architecture

MailAD uses a modular script architecture:

1. **Common Functions** (`common.conf`)
   - Shared utility functions
   - OS detection and handling
   - Package management helpers
   - Service control functions

2. **Specialized Scripts**
   - Installation scripts
   - Configuration deployment
   - Testing utilities
   - Maintenance tools

### Continuous Integration

#### GitHub Actions

MailAD uses GitHub Actions for CI/CD with the following workflows:

1. **MailAD Tests** (`mailad-tests.yml`)
   - Automated testing on multiple OS versions
   - Webmail login testing
   - Configuration validation
   - Security scanning

2. **Release Management**
   - Automated release notes generation
   - Version bumping
   - Documentation updates

#### Testing Matrix

- **Ubuntu**: 22.04 LTS, 24.04 LTS
- **Debian**: 11 (Bullseye), 12 (Bookworm)
- **Webmail**: RoundCube, SnappyMail
- **Features**: All optional features combinations

## Configuration Management

### Main Configuration File

The `/etc/mailad/mailad.conf` file is the central configuration point with the following structure:

#### Domain Configuration

```bash
# Basic domain settings
DOMAIN=mailad.cu
HOSTNAME=mail.mailad.cu
ADMINMAIL=pavelmc@mailad.cu
SYSADMINS=admins@mailad.cu
```

#### Network Configuration

```bash
# Network security settings
MYNETWORK="10.0.3.0/24"
RELAY=[gateway.mailad.cu]:26
MESSAGESIZE=2
DEFAULT_MAILBOX_SIZE=200M
```

#### LDAP Integration

```bash
# Active Directory connection
HOSTAD=dc.mailad.cu
SECURELDAP=no
LDAPBINDUSER="cn=linux,cn=Users,dc=mailad,dc=cu"
LDAPBINDPASSWD="Passw0rd---"
LDAPSEARCHBASE="ou=MAILAD,dc=mailad,dc=cu"
```

#### Security Features

```bash
# Filtering options
ENABLE_DNSBL=no
ENABLE_SPF=no
ENABLE_AV=no
ENABLE_SPAMD=no
ENABLE_DISCLAIMER=no
```

#### Webmail Configuration

```bash
# Web interface settings
WEBMAIL_ENABLED=no
WEBMAIL_APP=roundcube
WEBSERVER_HTTP_ENABLED=no
```

### Configuration Templates

MailAD uses template-based configuration with service-specific templates:

#### Dovecot Templates

- **Version 2.2**: `/var/dovecot-2.2/` - Legacy systems
- **Version 2.3**: `/var/dovecot-2.3/` - Modern systems
- **Version 2.4**: `/var/dovecot-2.4/` - Latest systems

#### Postfix Templates

- **Main Configuration**: `/var/postfix/main.cf`
- **Service Definitions**: `/var/postfix/master.cf`
- **LDAP Integration**: `/var/postfix/ldap/`
- **Filtering Rules**: `/var/postfix/rules/`

### Environment Variables

#### Required Variables

- `DOMAIN` - Primary mail domain
- `HOSTNAME` - Server hostname (FQDN)
- `ADMINMAIL` - Administrator email
- `HOSTAD` - Active Directory server

#### Optional Variables

- `SYSADMINS` - Group for notifications
- `RELAY` - Smart host configuration
- `MYNETWORK` - Trusted networks
- `WEBMAIL_ENABLED` - Webmail deployment

### Configuration Validation

MailAD includes comprehensive configuration validation:

1. **Syntax Checking**: Validates configuration file syntax
2. **Dependency Validation**: Checks required dependencies
3. **Network Testing**: Validates network connectivity
4. **LDAP Testing**: Tests Active Directory connectivity
5. **Security Validation**: Checks security configurations

## Security & Compliance

### Security Architecture

#### Network Security

- **Port Configuration**: Minimal exposed ports (25, 587, 993, 995)
- **Firewall Integration**: nftables configuration
- **Network Segmentation**: DMZ deployment recommendations
- **Access Control**: IP-based restrictions

#### Authentication Security

- **LDAP Security**: Optional SSL/TLS for LDAP connections
- **Password Policies**: Integration with AD password policies
- **Certificate Management**: Let's Encrypt and self-signed support
- **Access Logging**: Comprehensive authentication logging

#### Content Security

- **Virus Scanning**: ClamAV integration with multiple mirrors
- **Spam Filtering**: SpamAssassin with DNSBL integration
- **Content Filtering**: MIME type and extension filtering
- **Quarantine Management**: Automated quarantine handling

### Compliance Features

#### Cuban Regulatory Compliance

- **Email Size Limits**: Configurable message size restrictions
- **Access Control**: National/international access restrictions
- **Monitoring**: Daily traffic summaries
- **Audit Logging**: Comprehensive logging for compliance

#### Enterprise Security Standards

- **SSL/TLS**: Strong encryption with modern cipher suites
- **Certificate Validation**: Proper certificate chain validation
- **Security Headers**: Email security header management
- **Access Logging**: Detailed access and security logs

### Security Best Practices

#### Certificate Management

```bash
# Let's Encrypt integration
ENABLE_LETSENCRYPT=yes
LETSENCRYPT_EMAIL=admin@domain.com
LETSENCRYPT_DOMAINS="mail.domain.com,webmail.domain.com"
```

#### Access Control

```bash
# Restrict access by user groups
ENABLE_USER_PRIVILEGES=yes
LOCAL_ACCESS_GROUP="Local_mail"
NATIONAL_ACCESS_GROUP="National_mail"
```

#### Monitoring & Alerting

```bash
# Enable security monitoring
ENABLE_SECURITY_MONITORING=yes
SECURITY_ALERT_EMAIL=admin@domain.com
DAILY_SUMMARY_EMAIL=admin@domain.com
```

### Security Updates

#### Automated Updates

- **ClamAV**: Automatic virus definition updates
- **SpamAssassin**: Rule updates with DNS validation
- **System Packages**: Integration with system package managers
- **Security Patches**: Manual update process with validation

#### Update Validation

1. **Pre-update Testing**: Configuration validation
2. **Backup Creation**: Automatic backup before updates
3. **Rollback Capability**: Quick rollback on update failure
4. **Update Verification**: Post-update validation

## Operations & Maintenance

### Monitoring & Observability

#### System Monitoring

MailAD provides comprehensive monitoring capabilities:

1. **Daily Summaries**: Automated daily traffic reports
2. **Service Status**: Real-time service health monitoring
3. **Security Events**: Security incident logging
4. **Performance Metrics**: Mail server performance tracking

#### Log Management

```bash
# Log locations
/var/log/mail.log          # Mail server logs
/var/log/dovecot.log       # Dovecot logs
/var/log/clamav/           # ClamAV logs
/var/log/amavis/           # Amavisd-new logs
```

#### Monitoring Commands

```bash
# Check service status
systemctl status postfix dovecot amavis

# View mail logs
tail -f /var/log/mail.log

# Check mail queue
postqueue -p

# Monitor dovecot connections
dovecot -n | grep -A5 -B5 "mail_debug"
```

### Backup & Recovery

#### Backup Strategy

MailAD implements a comprehensive backup strategy:

1. **Configuration Backup**: Complete configuration backup
2. **Certificate Backup**: SSL certificate preservation
3. **User Data**: Mail storage backup (external)
4. **Database Backup**: LDAP and service database backup

#### Backup Commands

```bash
# Create backup
make backup

# List available backups
ls -la /var/backups/mailad/

# Restore from backup
make restore
```

#### Backup Contents

```bash
# Backup includes:
/etc/postfix/              # Postfix configuration
/etc/dovecot/              # Dovecot configuration
/etc/amavis/               # Amavisd-new configuration
/etc/clamav/               # ClamAV configuration
/etc/ssl/                  # SSL certificates
/etc/mailad/               # MailAD configuration
```

### Maintenance Procedures

#### Routine Maintenance

1. **Daily Tasks**
   - Check mail queue status
   - Review security logs
   - Monitor disk space usage
   - Verify service status

2. **Weekly Tasks**
   - Update virus definitions
   - Update spam rules
   - Review backup integrity
   - Check system updates

3. **Monthly Tasks**
   - Review security configurations
   - Update system packages
   - Test backup restoration
   - Review performance metrics

#### Update Procedures

```bash
# Check for updates
make check-new-version

# Update MailAD
make upgrade

# Update system packages
apt-get update && apt-get upgrade -y
```

### LXC Container Maintenance

#### Container Management

MailAD's LXC development environment requires regular maintenance to ensure optimal performance and reliability.

#### Routine Container Maintenance

1. **Container Status Monitoring**
   ```bash
   # Check all container status
   sudo lxc list
   
   # Check specific container
   sudo lxc info mailu
   
   # Monitor container resources
   sudo lxc exec mailu -- top
   ```

2. **Container Updates**
   ```bash
   # Update all containers
   sudo ansible-playbook -i local-dev/inventories/hosts.ini -b -m shell -a "apt update && apt upgrade -y" all
   
   # Update specific container
   sudo lxc exec mailu -- bash -c "apt update && apt upgrade -y"
   ```

3. **Container Cleanup**
   ```bash
   # Clean package cache in containers
   sudo lxc exec mailu -- apt clean
   sudo lxc exec maild -- apt clean
   
   # Remove unused packages
   sudo lxc exec mailu -- apt autoremove -y
   ```

#### Container Backup and Recovery

1. **Container Snapshots**
   ```bash
   # Create snapshot of mailu container
   sudo lxc stop mailu
   sudo lxc snapshot mailu backup-$(date +%Y%m%d)
   sudo lxc start mailu
   
   # List snapshots
   sudo lxc info mailu | grep -A10 "Snapshots"
   
   # Restore from snapshot
   sudo lxc stop mailu
   sudo lxc restore mailu backup-20231201
   sudo lxc start mailu
   ```

2. **Container Migration**
   ```bash
   # Export container
   sudo lxc stop mailu
   sudo lxc export mailu mailu-backup.tar.gz
   
   # Import container
   sudo lxc import mailu-backup.tar.gz
   sudo lxc start mailu
   ```

#### LXC Network Troubleshooting

1. **Network Connectivity Issues**
   ```bash
   # Check LXC network bridge
   sudo lxc network list
   
   # Check container network
   sudo lxc exec mailu -- ip addr show
   
   # Test container connectivity
   sudo lxc exec mailu -- ping -c 3 8.8.8.8
   ```

2. **DNS Resolution Problems**
   ```bash
   # Check DNS configuration
   sudo lxc exec mailu -- cat /etc/resolv.conf
   
   # Test DNS resolution
   sudo lxc exec mailu -- nslookup google.com
   
   # Restart DNS service
   sudo systemctl restart lxc-net
   ```

#### Container-Specific Troubleshooting

1. **DC Container Issues**
   ```bash
   # Check Samba status
   sudo lxc exec dc -- systemctl status samba-ad-dc
   
   # Test LDAP connectivity
   sudo lxc exec dc -- ldapsearch -x -b "dc=mailad,dc=cu"
   
   # Restart Samba services
   sudo lxc exec dc -- systemctl restart samba-ad-dc
   ```

2. **Mail Server Container Issues**
   ```bash
   # Check mail services
   sudo lxc exec mailu -- systemctl status postfix dovecot amavis
   
   # Test mail delivery
   sudo lxc exec mailu -- postqueue -p
   
   # Check mail logs
   sudo lxc exec mailu -- tail -f /var/log/mail.log
   ```

3. **Test Container Issues**
   ```bash
   # Check test environment
   sudo lxc exec test -- ls -la /root/mailad
   
   # Test network connectivity between containers
   sudo lxc exec test -- ping -c 3 10.0.3.3
   sudo lxc exec test -- ping -c 3 10.0.3.4
   ```

#### Common LXC Issues and Solutions

1. **Container Won't Start**
   ```bash
   # Check container logs
   sudo lxc info mailu --show-log
   
   # Check LXC storage
   sudo lxc storage list
   
   # Check available disk space
   df -h
   ```

2. **SSH Connection Problems**
   ```bash
   # Check SSH service
   sudo lxc exec mailu -- systemctl status ssh
   
   # Check SSH keys
   sudo lxc exec mailu -- ls -la /root/.ssh/
   
   # Regenerate SSH keys if needed
   sudo lxc exec mailu -- rm /etc/ssh/ssh_host_*
   sudo lxc exec mailu -- dpkg-reconfigure openssh-server
   ```

3. **MailAD Source Not Mounted**
   ```bash
   # Check mount points
   sudo lxc exec mailu -- mount | grep mailad
   
   # Check LXC configuration
   sudo lxc config show mailu
   
   # Restart container to remount
   sudo lxc restart mailu
   ```

#### Performance Optimization

1. **Container Resource Allocation**
   ```bash
   # Set memory limits
   sudo lxc config set mailu limits.memory 2GB
   
   # Set CPU limits
   sudo lxc config set mailu limits.cpu 2
   
   # Check current limits
   sudo lxc config show mailu
   ```

2. **Storage Optimization**
   ```bash
   # Check storage usage
   sudo lxc exec mailu -- df -h
   
   # Clean up mail storage
   sudo lxc exec mailu -- find /home/vmail -name "*.tmp" -delete
   
   # Optimize mail queue
   sudo lxc exec mailu -- postsuper -d ALL deferred
   ```

#### Security Considerations

1. **Container Isolation**
   - All containers run as root - use only in development environments
   - SSH keys are copied to containers - ensure proper key management
   - Network isolation is provided by LXC - don't expose containers to untrusted networks

2. **Security Updates**
   ```bash
   # Update container OS
   sudo lxc exec mailu -- apt update && sudo lxc exec mailu -- apt upgrade -y
   
   # Update MailAD source
   sudo lxc exec mailu -- git pull origin develop
   
   # Restart services after updates
   sudo lxc exec mailu -- systemctl restart postfix dovecot amavis
   ```

### Troubleshooting

#### Common Issues

1. **Mail Delivery Problems**
   ```bash
   # Check mail queue
   postqueue -p
   
   # Check mail logs
   tail -f /var/log/mail.log
   
   # Test SMTP connection
   telnet localhost 25
   ```

2. **Authentication Issues**
   ```bash
   # Test LDAP connection
   ldapsearch -x -H ldap://dc.domain.com -b "dc=domain,dc=com"
   
   # Check Dovecot logs
   tail -f /var/log/dovecot.log
   
   # Test authentication
   doveadm auth test username
   ```

3. **Performance Issues**
   ```bash
   # Check system resources
   top
   
   # Check mail queue size
   postqueue -p | wc -l
   
   # Monitor disk I/O
   iostat -x 1
   ```

#### Diagnostic Tools

1. **MailAD Diagnostics**
   ```bash
   # Run comprehensive tests
   make test
   
   # Check configuration
   make conf-check
   
   # Test LDAP connectivity
   scripts/test_bind_dn.sh
   ```

2. **Service Diagnostics**
   ```bash
   # Check service status
   systemctl status postfix dovecot amavis
   
   # View service logs
   journalctl -u postfix -f
   
   # Check configuration syntax
   postfix check
   dovecot -n
   ```

## Contributing Guidelines

### Getting Started

#### Development Setup

1. **Fork the Repository**
   ```bash
   git clone https://github.com/yourusername/mailad.git
   cd mailad
   ```

2. **Create Development Environment**
   ```bash
   # Set up configuration
   make conf
   
   # Install dependencies
   make deps
   
   # Create test environment
   make samba  # For AD testing
   ```

3. **Development Workflow**
   ```bash
   # Create feature branch
   git checkout -b feature/your-feature
   
   # Make changes
   # Test changes
   # Commit changes
   git commit -m "Refs #issue, description"
   
   # Push to fork
   git push origin feature/your-feature
   ```

#### Code Style Guidelines

1. **Shell Scripting**
   - Use `#!/bin/bash` shebang
   - Follow POSIX compliance where possible
   - Use descriptive variable names
   - Include error handling
   - Add comments for complex logic

2. **Configuration Files**
   - Use consistent indentation
   - Include descriptive comments
   - Follow existing patterns
   - Validate syntax before committing

3. **Documentation**
   - Use Markdown format
   - Include examples where helpful
   - Keep documentation up to date
   - Use clear, concise language

### Contribution Process

#### Issue Reporting

1. **Before Reporting**
   - Check existing issues
   - Verify against latest version
   - Test in clean environment

2. **Issue Template**
   ```markdown
   ## Description
   [Clear description of the issue]
   
   ## Steps to Reproduce
   1. [Step 1]
   2. [Step 2]
   3. [Expected vs actual behavior]
   
   ## Environment
   - OS: [Ubuntu 24.04, etc.]
   - MailAD Version: [v1.2.5]
   - Configuration: [Relevant config settings]
   
   ## Logs
   [Relevant log entries]
   ```

#### Pull Request Process

1. **Before Creating PR**
   - Ensure tests pass
   - Update documentation if needed
   - Follow coding standards
   - Test on multiple platforms if possible

2. **PR Template**
   ```markdown
   ## Summary
   [Brief description of changes]
   
   ## Test plan
   [How to test the changes]
   
   ## Documentation
   [Any documentation changes needed]
   
   ## Breaking Changes
   [List any breaking changes]
   ```

### Development Standards

#### Testing Requirements

1. **Unit Tests**: Test individual functions and scripts
2. **Integration Tests**: Test component interactions
3. **System Tests**: Test complete system functionality
4. **Security Tests**: Test security configurations

#### Code Review Process

1. **Automated Checks**: All CI/CD checks must pass
2. **Manual Review**: At least one maintainer review required
3. **Testing**: Changes must be tested on target platforms
4. **Documentation**: Documentation updates required for user-facing changes

#### Release Process

1. **Feature Freeze**: Stop accepting new features before release
2. **Testing Phase**: Comprehensive testing of release candidate
3. **Documentation**: Update documentation and changelog
4. **Release**: Create release tag and publish

### Community Guidelines

#### Communication

- **GitHub Issues**: For bug reports and feature requests
- **Telegram Group**: For community discussion and support
- **Email**: For direct communication with maintainers

#### Support Expectations

- **Response Time**: 48-72 hours for issue responses
- **Support Scope**: Bug fixes and security updates
- **Community Support**: Community-driven support encouraged

## Dependencies & Requirements

### System Requirements

#### Minimum Requirements

- **CPU**: 2 cores
- **RAM**: 2GB (1GB without AV/Spam filtering)
- **Storage**: 2GB (plus mail storage)
- **Network**: Internet access for updates

#### Recommended Requirements

- **CPU**: 4 cores
- **RAM**: 4GB
- **Storage**: 20GB SSD (plus mail storage)
- **Network**: Reliable internet connection

#### Supported Operating Systems

**Active Support:**
- Ubuntu 24.04 LTS (Noble)
- Debian 12 (Bookworm)

**Legacy Support:**
- Ubuntu 22.04 LTS (Jammy)
- Debian 11 (Bullseye)

**Discontinued:**
- Ubuntu 20.04 LTS (Focal)
- Debian 10 (Buster)
- Ubuntu 18.04 LTS (Bionic)

### Software Dependencies

#### Core Dependencies

```bash
# Mail server components
postfix postfix-pcre postfix-ldap
dovecot-core dovecot-pop3d dovecot-imapd dovecot-ldap
dovecot-sieve dovecot-managesieved

# Security components
amavisd-new clamav clamav-daemon clamav-freshclam
spamassassin

# System utilities
ldap-utils libnet-ldap-perl rsync
dnsutils pflogsumm mailutils
```

#### Optional Dependencies

```bash
# Webmail components
nginx php-fpm php-dom php-mbstring php-bz2 php-zip
php-json php-xml php-net-ldap3 php-ldap php-gd
php-exif php-sqlite3 php-tidy

# RoundCube
roundcube roundcube-sqlite3 roundcube-plugins-extra

# SnappyMail
# Downloaded automatically during installation
```

#### Development Dependencies

```bash
# Testing tools
curl wget netcat-traditional
openssl ca-certificates

# Development tools
git make vim

# Testing environments
lxc lxd vagrant virtualbox
```

### External Dependencies

#### Active Directory

- **Windows Server**: 2012 R2 or later
- **Samba**: 4.0 or later
- **LDAP**: Port 389 (unencrypted) or 636 (LDAPS)
- **DNS**: Proper DNS resolution for domain controllers

#### Certificate Authorities

- **Let's Encrypt**: Automated certificate management
- **Self-signed**: Built-in certificate generation
- **Commercial CAs**: Manual certificate installation

#### External Services

- **DNSBL**: Multiple DNS blacklist services
- **SpamAssassin**: Rule updates from various sources
- **ClamAV**: Virus definition updates from multiple mirrors

### Compatibility Matrix

| Component | Ubuntu 24.04 | Ubuntu 22.04 | Debian 12 | Debian 11 |
|-----------|-------------|-------------|-----------|-----------|
| Postfix   | ✓ 3.6+      | ✓ 3.4+      | ✓ 3.6+    | ✓ 3.4+    |
| Dovecot   | ✓ 2.3.16+   | ✓ 2.3.4+    | ✓ 2.3.16+ | ✓ 2.3.4+  |
| Amavisd   | ✓ 1:2.12+   | ✓ 1:2.11+   | ✓ 1:2.12+ | ✓ 1:2.11+ |
| ClamAV    | ✓ 1.1+      | ✓ 0.103+    | ✓ 1.1+    | ✓ 0.103+  |
| SpamAss   | ✓ 4.0+      | ✓ 3.4+      | ✓ 4.0+    | ✓ 3.4+    |

## Testing Strategy

### Test Types

#### Unit Tests

- **Script Functions**: Individual function testing
- **Configuration Parsing**: Config file validation
- **Utility Functions**: Helper function testing
- **Error Handling**: Error condition testing

#### Integration Tests

- **Service Integration**: Component interaction testing
- **LDAP Integration**: Active Directory connectivity
- **Webmail Integration**: Web interface testing
- **Security Integration**: Security feature testing

#### System Tests

- **End-to-End Mail Flow**: Complete mail delivery testing
- **Authentication Testing**: User authentication validation
- **Security Testing**: Security feature validation
- **Performance Testing**: Load and performance testing

#### Regression Tests

- **Feature Preservation**: Ensure existing features work
- **Configuration Compatibility**: Config file compatibility
- **Upgrade Testing**: Version upgrade validation
- **Security Regression**: Security feature preservation

### Test Environment Setup

#### Local Testing

```bash
# Create test environment
make deps
make conf

# Set up test Active Directory
make samba

# Run basic tests
make test
```

#### Automated Testing

```bash
# Run all tests
./tests/test.sh

# Test specific components
./tests/test.sh --component=postfix
./tests/test.sh --component=dovecot
./tests/test.sh --component=webmail
```

#### Test Configuration

```bash
# Test credentials file
.mailadmin.auth

# Test configuration
.mailad.auth

# Test parameters
IP=192.168.1.100
DOMAIN=test.mailad.cu
```

### Test Coverage

#### Core Functionality

- **Mail Delivery**: SMTP, IMAP, POP3 functionality
- **Authentication**: LDAP/AD authentication
- **Security**: Spam, virus, and content filtering
- **Configuration**: Configuration file validation

#### Optional Features

- **Webmail**: RoundCube and SnappyMail
- **SSL/TLS**: Certificate management
- **DNSBL**: DNS blacklist functionality
- **SPF**: Sender Policy Framework validation

#### Edge Cases

- **Large Messages**: Message size limit testing
- **High Load**: Performance under load
- **Network Issues**: Network connectivity problems
- **Configuration Errors**: Invalid configuration handling

### Continuous Integration

#### GitHub Actions Workflow

```yaml
# .github/workflows/mailad-tests.yml
name: MailAD Tests
on: [push, pull_request]
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-22.04, ubuntu-24.04]
        webmail: [roundcube, snappy]
    steps:
      - uses: actions/checkout@v3
      - name: Setup environment
        run: |
          make deps
          make conf
      - name: Run tests
        run: make test
```

#### Test Automation

1. **Automated Testing**: All commits trigger automated tests
2. **Multi-platform Testing**: Tests run on all supported platforms
3. **Feature Testing**: All optional features tested
4. **Security Testing**: Security features validated

### Performance Testing

#### Load Testing

- **Mail Queue**: Queue handling under load
- **Authentication**: Concurrent authentication testing
- **Storage**: Mail storage performance
- **Network**: Network throughput testing

#### Resource Monitoring

- **Memory Usage**: RAM consumption monitoring
- **CPU Usage**: CPU utilization tracking
- **Disk I/O**: Storage performance monitoring
- **Network I/O**: Network performance tracking

## Deployment & Scaling

### Deployment Strategies

#### Single Server Deployment

**Use Case**: Small to medium deployments
**Components**: All services on single server
**Storage**: Local storage or network mount
**Backup**: Local backup strategy

```bash
# Single server deployment
make provision
make webmail  # Optional
```

#### Distributed Deployment

**Use Case**: Large deployments with high availability
**Components**: Services distributed across multiple servers
**Storage**: Centralized storage (NFS, SAN)
**Backup**: Enterprise backup solutions

```bash
# Distributed deployment components
# Mail Server: Postfix + Dovecot
# Filter Server: Amavisd-new + ClamAV + SpamAssassin
# Web Server: Nginx + PHP + Webmail
# Storage Server: Centralized mail storage
```

#### Container Deployment

**Use Case**: Development and testing environments
**Components**: Docker containers for each service
**Storage**: Docker volumes or external storage
**Networking**: Docker networking

```bash
# Container deployment (limited support)
docker-compose up -d
```

### Scaling Considerations

#### Vertical Scaling

- **CPU**: More cores for mail processing
- **RAM**: More memory for caching and processing
- **Storage**: Faster storage for mail delivery
- **Network**: Higher bandwidth for mail throughput

#### Horizontal Scaling

- **Load Balancing**: Distribute load across multiple servers
- **Database Scaling**: Scale LDAP/AD infrastructure
- **Storage Scaling**: Distributed storage solutions
- **Network Scaling**: Multiple network interfaces

### High Availability

#### Service Redundancy

- **Mail Transport**: Multiple Postfix instances
- **Mail Access**: Multiple Dovecot instances
- **Filtering**: Multiple Amavisd-new instances
- **Web Interface**: Multiple web server instances

#### Data Replication

- **Mail Storage**: Real-time mail storage replication
- **Configuration**: Configuration synchronization
- **Certificates**: Certificate distribution
- **Logs**: Centralized logging

#### Failover Procedures

1. **Service Failover**: Automatic service failover
2. **Data Failover**: Data replication and failover
3. **DNS Failover**: DNS-based failover
4. **Manual Failover**: Manual intervention procedures

### Production Deployment

#### Pre-deployment Checklist

1. **Environment Preparation**
   - Server hardware verification
   - Network configuration
   - Storage setup
   - Security configuration

2. **Configuration Validation**
   - MailAD configuration review
   - Security settings validation
   - Performance tuning
   - Backup strategy setup

3. **Testing**
   - Functional testing
   - Performance testing
   - Security testing
   - Integration testing

#### Deployment Process

1. **Initial Setup**
   ```bash
   # Install dependencies
   make deps
   
   # Configure system
   make conf
   
   # Install mail server
   make install
   ```

2. **Configuration Deployment**
   ```bash
   # Deploy configuration
   make provision
   
   # Test configuration
   make test
   ```

3. **Service Activation**
   ```bash
   # Start services
   make services start
   
   # Verify operation
   make test
   ```

#### Post-deployment

1. **Monitoring Setup**
   - Configure monitoring tools
   - Set up alerting
   - Establish baselines
   - Monitor performance

2. **Documentation**
   - Document configuration
   - Create runbooks
   - Train operations team
   - Establish procedures

### Migration Strategies

#### From Existing Mail Server

1. **Assessment**
   - Current mail server analysis
   - User migration planning
   - Data migration strategy
   - Downtime planning

2. **Migration Process**
   ```bash
   # Phase 1: Setup new server
   make provision
   
   # Phase 2: Migrate users
   # Use LDAP synchronization tools
   
   # Phase 3: Migrate mail data
   # Use mail migration tools
   
   # Phase 4: Cutover
   # Update DNS records
   # Monitor migration
   ```

3. **Validation**
   - User access verification
   - Mail delivery testing
   - Performance validation
   - Security verification

#### Between MailAD Versions

1. **Backup**: Create complete backup
2. **Test**: Test upgrade in staging environment
3. **Upgrade**: Perform upgrade with `make upgrade`
4. **Validate**: Verify all functionality
5. **Monitor**: Monitor for issues

## Troubleshooting

### Common Issues & Solutions

#### Installation Issues

**Problem**: Dependencies installation fails
```bash
# Solution: Check repository configuration
apt-get update
apt-get install -f

# Check for conflicting packages
dpkg --get-selections | grep postfix
dpkg --get-selections | grep dovecot
```

**Problem**: Configuration validation fails
```bash
# Solution: Check configuration syntax
make conf-check

# Check specific configuration
postfix check
dovecot -n
```

#### Authentication Issues

**Problem**: LDAP authentication fails
```bash
# Solution: Test LDAP connectivity
ldapsearch -x -H ldap://dc.domain.com -b "dc=domain,dc=com"

# Check bind credentials
scripts/test_bind_dn.sh

# Verify user exists
ldapsearch -x -H ldap://dc.domain.com -b "ou=MAILAD,dc=domain,dc=com" "(mail=user@domain.com)"
```

**Problem**: Dovecot authentication fails
```bash
# Solution: Check Dovecot logs
tail -f /var/log/dovecot.log

# Test authentication
doveadm auth test username

# Check configuration
dovecot -n | grep -A5 -B5 auth
```

#### Mail Delivery Issues

**Problem**: Mail not being delivered
```bash
# Solution: Check mail queue
postqueue -p

# Check mail logs
tail -f /var/log/mail.log

# Test SMTP connection
telnet localhost 25
```

**Problem**: Mail being marked as spam
```bash
# Solution: Check spam filtering
tail -f /var/log/amavis.log

# Test spam detection
echo "Test message" | spamassassin

# Check configuration
amavisd-new showconf | grep -i spam
```

#### Performance Issues

**Problem**: High resource usage
```bash
# Solution: Check resource usage
top
iostat -x 1
netstat -i

# Check mail queue size
postqueue -p | wc -l

# Check active connections
netstat -an | grep :25 | wc -l
```

**Problem**: Slow mail delivery
```bash
# Solution: Check mail queue
postqueue -p

# Check DNS resolution
dig domain.com MX

# Check network connectivity
ping mail.domain.com
```

### Diagnostic Tools

#### MailAD Diagnostic Scripts

```bash
# Comprehensive system check
scripts/test_localhost.sh

# LDAP connectivity test
scripts/test_bind_dn.sh

# Mail admin test
scripts/test_mailadmin.sh

# DNS records check
scripts/check_dns_records.sh
```

#### System Diagnostic Commands

```bash
# Service status
systemctl status postfix dovecot amavis

# Service logs
journalctl -u postfix -f
journalctl -u dovecot -f
journalctl -u amavis -f

# Configuration validation
postfix check
dovecot -n
amavisd-new showconf
```

#### Network Diagnostics

```bash
# Port connectivity
nc -zv localhost 25
nc -zv localhost 993
nc -zv localhost 587

# DNS resolution
dig domain.com MX
dig domain.com A
dig domain.com AAAA

# Network interface status
ip addr show
ip route show
```

### Log Analysis

#### Mail Server Logs

```bash
# Mail delivery logs
tail -f /var/log/mail.log | grep "status=sent"

# Authentication logs
tail -f /var/log/mail.log | grep "authentication"

# Error logs
tail -f /var/log/mail.log | grep "error"
```

#### Service Logs

```bash
# Dovecot logs
tail -f /var/log/dovecot.log

# Amavisd-new logs
tail -f /var/log/amavis.log

# ClamAV logs
tail -f /var/log/clamav/clamd.log
```

#### System Logs

```bash
# System messages
tail -f /var/log/syslog

# Authentication logs
tail -f /var/log/auth.log

# Security logs
tail -f /var/log/kern.log
```

### Emergency Procedures

#### Service Recovery

```bash
# Restart all mail services
systemctl restart postfix dovecot amavis

# Check service status
systemctl status postfix dovecot amavis

# Verify service operation
make test
```

#### Configuration Recovery

```bash
# Restore from backup
make restore

# Verify configuration
make conf-check

# Test services
make test
```

#### Data Recovery

```bash
# Check mail storage
ls -la /home/vmail/

# Verify mail delivery
echo "Test" | mail -s "Test" user@domain.com

# Check mail queue
postqueue -p
```

### Support Resources

#### Documentation

- [README.md](README.md) - Main project documentation
- [INSTALL.md](INSTALL.md) - Installation guide
- [Features.md](Features.md) - Feature documentation
- [FAQ.md](FAQ.md) - Frequently asked questions

#### Community Support

- **GitHub Issues**: Bug reports and feature requests
- **Telegram Group**: [MailAD Dev](https://t.me/MailAD_dev) - Community discussion
- **Email**: pavelmc@gmail.com - Direct contact

#### Professional Support

For enterprise support and consulting services, contact the maintainer directly for availability and pricing information.

---

**Note**: This document is maintained by the MailAD development team and community. For the most up-to-date information, always refer to the latest version in the repository.