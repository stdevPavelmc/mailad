# MailAD GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated testing of MailAD.

## mailad-vm-tests.yml

This workflow performs integration testing of MailAD by using three separate GitHub Actions VMs:

1. **Samba AD VM**: Sets up a Samba Active Directory server using the `samba_scaffold.sh` script.
2. **MailAD Server VM**: Installs and configures a full MailAD installation.
3. **Test Client VM**: Runs the test suite against the MailAD server.

### Workflow Details

The workflow consists of four jobs:

1. **Setup Job**:
   - Creates the `.mailadmin.auth` file with test credentials
   - Generates the `mailad.conf` configuration file
   - Uploads the repository as an artifact for other jobs to use

2. **Samba AD Job**:
   - Downloads the repository and configuration files
   - Sets up the Samba AD server using `samba_scaffold.sh`
   - Exports its IP address for other jobs to use

3. **MailAD Server Job**:
   - Downloads the repository and configuration files
   - Configures the MailAD server to use the Samba AD server
   - Installs and configures MailAD using `make all`
   - Exports its IP address for the test client to use

4. **Test Client Job**:
   - Downloads the repository and configuration files
   - Configures networking to communicate with the other VMs
   - Installs test dependencies
   - Runs the test suite against the MailAD server
   - Uploads test logs as artifacts

### Key Features

- **Full VM Testing**: Uses complete Ubuntu VMs instead of Docker containers for more realistic testing
- **Credential Management**: Generates temporary credentials for testing
- **Network Configuration**: Sets up proper networking between VMs using `/etc/hosts`
- **Comprehensive Testing**: Runs the full test suite from the `tests/test.sh` script
- **Log Collection**: Collects and uploads test logs for debugging

### Troubleshooting

If tests fail, check the uploaded logs in the workflow artifacts. Common issues include:

- Network connectivity problems between VMs
- Incorrect configuration of the Samba AD server
- MailAD installation or configuration issues
- Test script failures

## mailad-tests.yml (Docker-based alternative)

This is an alternative workflow that uses Docker containers instead of full VMs. It may be more efficient for some testing scenarios but doesn't provide the full VM isolation.

See the workflow file for details on how it works.

