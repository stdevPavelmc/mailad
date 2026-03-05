# MailAD LXC Development Environment

This directory contains Ansible playbooks for creating and managing LXC (Linux Containers) test hosts for MailAD development and testing. These containers provide isolated environments to test MailAD installations across different operating systems and configurations.

## Overview

The LXC setup creates a complete test environment with:

- **DC (Domain Controller)**: Ubuntu Noble - Active Directory/Samba server
- **mailu**: Ubuntu Noble - Mail server for testing Ubuntu-based installations
- **maild**: Debian Bookworm - Mail server for testing Debian-based installations  
- **test**: Ubuntu Noble - General-purpose test environment

All containers are configured with:
- Local package repository access for faster installations
- SSH key authentication for easy access
- Network connectivity via LXC bridge (10.0.3.x subnet)
- MailAD source code mounted at `/root/mailad`

## Prerequisites

### System Requirements
- Ubuntu 20.04+ or Debian 10+ host system
- Root access (required for LXC operations)
- At least 8GB RAM recommended
- 20GB+ free disk space
- Internet connection for initial setup

### Required Software
```bash
# Install LXC and dependencies
sudo apt update
sudo snap install lxd
sudo apt install python3-lxc ansible dnsmask dnsmasq-base dnsmasq-utils

# Install Ansible community collection
ansible-galaxy collection install community.general
```

### LXC Setup
Before running the playbooks, ensure LXC is properly configured:

```bash
# Initialize LXC (follow prompts to configure storage, network, etc.)
sudo lxd init

# Verify LXC is working
sudo lxc list
```

### LXC network setup

See the page on LXC for detailed explanations: https://linuxcontainers.org/lxc/getting-started/

Get sure you configured the `/etc/lxc/default.conf` file with a proper network setting, this is the bare minimum:

```ini
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up

lxc.apparmor.profile = generated
lxc.apparmor.allow_nesting = 1
```

You must also configure the dnsmasq dhcp for the names of the hosts to secure stable IPs, edit/create the `/etc/lxc/dnsmasq.conf` file with this content:

```ini
# defaults
domain=mailad.cu

# reservations
dhcp-host=dc,10.0.3.2 
dhcp-host=mailu,10.0.3.3  
dhcp-host=maild,10.0.3.4 
dhcp-host=test,10.0.3.5
```

Also setup the loading of that file via lxc in the file `/etc/default/lxc-net`:

```ini
SE_LXC_BRIDGE="true"

# use custom dns
LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf
LXC_DHCP_RANGE="10.0.3.1,10.0.3.254"
```

## Quick Start

### Create LXC Test Environment
Run this command **as root** to create all test containers:

```bash
sudo ansible-playbook playbooks/create_lxc.yml
```

This will:
1. Install required dependencies
2. Create 4 LXC containers with specified OS versions
3. Configure networking and SSH access
4. Set up local package repositories
5. Install basic development tools

### Remove LXC Test Environment
To clean up and remove all test containers:

```bash
sudo ansible-playbook playbooks/remove_lxc.yml
```

## Detailed Setup

### 1. Configuration

The setup is controlled by configuration files:

- **`vars/general.yml`**: Defines container specifications, OS versions, and global settings
- **`inventories/hosts.ini`**: Network configuration and container IP assignments
- **`templates/repos/`**: Package repository configurations for local mirrors

#### Customizing Container Configuration

Edit `vars/general.yml` to modify:

```yaml
# Change timezone
timezone: "America/Havana"

# Modify domain settings
domain: mailad.cu

# Add/remove containers
lxcs:
  dc:
    distro: ubuntu
    release: noble
  # Add more containers as needed
```

#### Network Configuration

Containers are assigned IPs in the 10.0.3.x subnet:
- DC: 10.0.3.2
- mailu: 10.0.3.3  
- maild: 10.0.3.4
- test: 10.0.3.5

Note: this IP assignation is linked to the lxc config stated above, if you chante it, then you need to change the lxc configuration.

### 2. Repository Configuration

The setup configures local package repositories for faster installations. Edit the repository settings in `vars/general.yml`:

```yaml
repos:
  ubuntu:
    host: 192.168.1.102  # Change to your local mirror IP
    port: 80
  debian:
    host: 192.168.1.102  # Change to your local mirror IP
    port: 80
```

Script expect /ubuntu or /debian after host in the URL acordingly; If you don't have a local mirror, comment out the repository injection tasks in the playbook.

## Usage Examples

### Accessing Containers

Once created, access containers directly:

```bash
# Access via LXC [preferred/default way]
# sudo lxc-execute *container -- bash -c "*commands"
sudo lxc-execute mailu -- bash -c "cd /root/mailad/ ; make conf"

# Check container status
sudo lxc-ls -f
```

All commands inside the containers from the host must be ran this way.

### Testing MailAD Installation

Each container has the MailAD source code mounted at `/root/mailad`, you need to setup the dependencies and basic config file there.

```bash
# Inside all containers
cd /root/mailad
make deps    # Install dependencies
make conf    # Configure

# sudo lxc-execute mailu -- bash -c "cd /root/mailad/ ; make deps ; make conf"
```

#### Setting specific details for each container

##### dc container

You need to scaffold the samba install if the container is just created

```bash
cd /root/mailad
make samba   # Install samba, dependencies and scaffold the bare DC settings to operate

# sudo lxc-execute dc -- bash -c "cd /root/mailad/ ; make samba"
```

##### mailu and maild container

1. You need to set the hostname for that container on the maild config file

```bash
# For both containers
# Replace the default mail hostname with the host one
sed "s|HOSTNAME\=mail\.mailad\.cu|HOSTNAME=$(hostname).mailad.cu|" -i /etc/mailad/mailad.conf

# sudo lxc-execute [container] -- bash -c 'sed "s|HOSTNAME\=mail\.mailad\.cu|HOSTNAME=$(hostname).mailad.cu|" -i /etc/mailad/mailad.conf'
```

2. Add the test container IP as an exclusion to the MYNETWORKS variable

```bash
# For both containers
# Exclude the test container IP from mynetworks
sed 's/MYNETWORK="\(.*\)"/MYNETWORK="!10.0.3.5 \1"/' -i /etc/mailad/mailad.conf

# sudo lxc-execute [container] -- bash -c 'sed \'s/MYNETWORK="\(.*\)"/MYNETWORK="!10.0.3.5 \1"/\' -i /etc/mailad/mailad.conf'
```

3. Provision the mail server to get them up and runing for the tests

```bash
# For both containers
# Ran the provision command
make provision

# sudo lxc-execute [container] -- bash -c "cd /root/mailad/ ; make provision"
```

### Testing default working status

Test MailAD on different operating systems/containers, this will ran the default test battery for each os container:

```bash
# Test on Ubuntu (pass the IP of the ubuntu container)
sudo lxc-attach test -- bash -c "cd /root/mailad && ./tests/test.sh 10.0.3.3"

# Test on Debian (pass the IP of the debian container)
sudo lxc-attach test -- bash -c "cd /root/mailad && ./tests/test.sh 10.0.3.4"
```

### Network Testing

Test mail server connectivity:

```bash
# Connectivity from test to mailu
sudo lxc-attach test -- ping 10.0.3.3

# Connectivity from test to maild
sudo lxc-attach test -- ping 10.0.3.4

# Following must get the service headers
# Test SMTP/IMAP from test container to mailu containers
sudo lxc-attach test -- timeout 1 nc 10.0.3.3 25
sudo lxc-attach test -- timeout 1 nc 10.0.3.3 143

# Test SMTP/IMAP from test container to maild containers
sudo lxc-attach test -- timeout 1 nc 10.0.3.3 25
sudo lxc-attach test -- timeout 1 nc 10.0.3.3 143
```

## Troubleshooting

### Common Issues

#### Package Installation Fails
```bash
# Check repository configuration
sudo lxc-attach mailu -- cat /etc/apt/sources.list

# Test network connectivity
sudo lxc-attach mailu -- ping -c 3 8.8.8.8
```

#### MailAD Dependencies Fail
```bash
# Check package manager
sudo lxc-attach mailu -- apt update

# Check Python availability
sudo lxc-attach mailu -- python3 --version
```

### Debug Commands

```bash
# View container logs
sudo lxc-attach mailu -- journalctl -f

# Check container resources
sudo lxc-attach mailu -- top

# Verify MailAD source mount
sudo lxc-attach mailu -- ls -la /root/mailad
```

## Maintenance

### Updating Containers

To update packages in all containers:

```bash
# Update all containers
sudo ansible-playbook -i inventories/hosts.ini -b -m shell -a "apt update && apt upgrade -y" all
```

### Backup and Restore

#### Backup Container State
```bash
# Stop container
sudo lxc stop mailu

# Create snapshot
sudo lxc snapshot mailu backup-$(date +%Y%m%d)

# Restart container
sudo lxc start mailu
```

#### Restore from Snapshot
```bash
# Restore snapshot
sudo lxc restore mailu backup-20231201

# Start container
sudo lxc start mailu
```

### Cleanup

Remove all containers and reset environment:

```bash
# Remove all containers
sudo ansible-playbook playbooks/remove_lxc.yml
```

## Integration with MailAD Development

### Testing Workflow

1. **Create test environment**:
   ```bash
   sudo ansible-playbook playbooks/create_lxc.yml
   ```

2. **Test MailAD installation**:
   ```bash
   sudo lxc-attach mailu -- bash -c "cd /root/mailad && make test"
   ```

3. **Test cross-platform compatibility**:
   ```bash
   sudo lxc-attach maild -- bash -c "cd /root/mailad && make test"
   ```

4. **Clean up**:
   ```bash
   sudo ansible-playbook playbooks/remove_lxc.yml
   ```

### Continuous Integration

This LXC setup can be integrated into CI/CD pipelines for automated testing across multiple operating systems.

## Security Considerations

- All containers run as root - use only in development environments
- SSH keys are copied to containers - ensure proper key management
- Local repositories may contain untrusted packages - verify sources
- Network isolation is provided by LXC - don't expose containers to untrusted networks

## Support

For issues with this LXC setup:

1. Check the [MailAD documentation](../README.md)
2. Review the [MailAD FAQ](../FAQ.md)
3. Report issues on [GitHub](https://github.com/stdevPavelmc/mailad/issues)

## License

This LXC setup is part of the MailAD project and is licensed under GPL v3.