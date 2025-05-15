# MailAD GitHub Actions Workflow

This directory contains GitHub Actions workflows for automated testing of MailAD.

## mailad-tests.yml

This workflow performs integration testing of MailAD by spinning up three Docker containers:

1. **Samba AD Container**: Sets up a Samba Active Directory server using the `samba_scaffold.sh` script.
2. **MailAD Server Container**: Installs and configures a full MailAD installation.
3. **Test Client Container**: Runs the test suite against the MailAD server.

### Workflow Details

The workflow performs the following steps:

1. **Setup**: Creates a Docker network and starts three containers.
2. **Configuration**: 
   - Configures `/etc/hosts` in each container for proper name resolution.
   - Generates a `.mailadmin.auth` file with test credentials.
   - Runs `make conf` on all containers to create the configuration files.

3. **Samba AD Setup**: 
   - Runs the `samba_scaffold.sh` script to set up the Samba AD server.
   - Creates test users and groups as specified in the `.mailadmin.auth` file.

4. **MailAD Server Setup**:
   - Configures the MailAD server to use the Samba AD server.
   - Disables the SOA test for the testing environment.
   - Runs `make all` to install and configure MailAD.

5. **Test Execution**:
   - Installs test dependencies on the test client.
   - Runs the `test.sh` script against the MailAD server.
   - Fails the workflow if any tests fail.

6. **Log Collection**:
   - On failure, collects logs from all containers.
   - Uploads logs as artifacts for debugging.

7. **Cleanup**:
   - Stops and removes all containers.
   - Removes the Docker network.
   - Deletes temporary files.

### Customization

You can customize the workflow by modifying the following:

- **Credentials**: Update the `.mailadmin.auth` file generation to use different passwords.
- **Container Images**: Change the base image (currently `ubuntu:22.04`) if needed.
- **Test Parameters**: Modify the test execution command to include additional parameters.

### Troubleshooting

If tests fail, check the uploaded logs in the workflow artifacts. Common issues include:

- Network connectivity problems between containers
- Incorrect configuration of the Samba AD server
- MailAD installation or configuration issues
- Test script failures

The logs collected include:
- Journal logs from the MailAD server
- Journal logs from the Samba AD server
- Test execution logs from the test client

