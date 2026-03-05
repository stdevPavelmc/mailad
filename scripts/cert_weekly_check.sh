#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2025 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check if the SSL certificate for an IMAP server is valid
#   - Warn the syadmins if the certificate is about to expire, or expired.

# Configuration variables taken from mailad config file
source /etc/mailad/mailad.conf

# hostname:port to check
HOSTNAME_SERVICE="${HOSTNAME}:995"
# weeks before expiration to warn
BEFORE_WARNING=3

# Fill in the missing variables
if [ -z "${SYSADMINS}" ] ; then
    SYSADMINS="${ADMINMAIL}"
fi

# SWAKS configuration
SMTP_SERVER="${HOSTNAME}"
FROM_EMAIL="${ADMINMAIL}"

# Instructions on how to update/regen the certs
INSTRUCTIONS="If you are using a Let's Encrypt certificate, please renew the certificate
and follows the instructions on the link below:

https://github.com/stdevPavelmc/mailad/blob/master/INSTALL.md#certificate-creation

If you are using a self-signed certificate, please renew the certificate.

How? it's simple, Open a console on the server and move to the folder where
you cloned MailAD, then ran this commands as root.

---
make cert-ssc-renew
---

If all goes well you will see an email with the report of your SSL cert check.
"

# Function to send email via swaks
send_email() {
    echo "$2" | swaks \
        --to "$SYSADMINS" \
        --from "$FROM_EMAIL" \
        --server "$SMTP_SERVER" \
        --h-Subject "$1" \
        --body - \
        --suppress-data &>/dev/null 
}

# Function to check SSL certificate
check_ssl_cert() {
    local host_port="$1"
    local host=$(echo "$host_port" | cut -d: -f1)
    local port=$(echo "$host_port" | cut -d: -f2)
    
    # Get certificate expiration date
    local cert_info
    cert_info=$(echo | timeout 10 openssl s_client -connect "$host_port" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
    
    if [[ $? -ne 0 || -z "$cert_info" ]]; then
        send_email "MailAD: SSL Certificate Check Failed - $host_port" \
                  "Failed to retrieve SSL certificate from $host_port

This could indicate:
- Service is down
- Network connectivity issues
- SSL/TLS configuration problems

Please investigate immediately.

Checked from: $(hostname)
Date: $(date)"
        return 1
    fi
    
    # Extract expiration date
    local exp_date
    exp_date=$(echo "$cert_info" | grep "notAfter=" | cut -d= -f2)
    
    if [[ -z "$exp_date" ]]; then
        echo "ERROR: Could not parse expiration date"
        return 1
    fi
    
    # Convert dates to seconds since epoch
    local exp_epoch
    exp_epoch=$(date -d "$exp_date" +%s 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    local current_epoch=$(date +%s)
    local warning_epoch=$((current_epoch + (BEFORE_WARNING * 7 * 24 * 3600)))
    
    # Calculate days until expiration
    local days_left=$(( (exp_epoch - current_epoch) / 86400 ))
    
    # Check certificate status
    if [[ $exp_epoch -lt $current_epoch ]]; then # lt
        # Certificate has expired
        send_email "MailAD: URGENT SSL Certificate EXPIRED - $host_port" \
                   "CRITICAL ALERT: SSL Certificate has EXPIRED

Service: $host_port
Expired on: $exp_date
Days overdue: $((days_left * -1))

This service is likely experiencing SSL/TLS connection failures.
IMMEDIATE ACTION REQUIRED to renew the certificate.

${INSTRUCTIONS}

Checked from: $(hostname)
Date: $(date)"
        return 2

    elif [[ $exp_epoch -lt $warning_epoch ]]; then # lt
        # Certificate expires within warning period
        send_email "MailAD: SSL Certificate Expiring Soon - $host_port" \
                  "SSL Certificate Expiration Warning

Service: $host_port
Expires on: $exp_date
Days remaining: $days_left
Warning threshold: $BEFORE_WARNING weeks

Please renew the certificate before it expires to avoid service disruption.

${INSTRUCTIONS}

Checked from: $(hostname)
Date: $(date)"
        return 3
    else
        return 0
    fi
}

# Check if required tools are available
for tool in openssl swaks timeout; do
    if ! command -v "$tool" &> /dev/null; then
        exit 1
    fi
done

# Perform the check
check_ssl_cert "$HOSTNAME_SERVICE"
results=$?

case $results in
    1) echo "Check failed - Could not retrieve certificate" ;;
    2) echo "Check completed - Certificate has EXPIRED" ;;
    3) echo "Check completed - Certificate expires soon" ;;
esac

exit $results
