#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2025 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Check for common DNS records for the domain and report back any issues and recommendations
#   - SPF, DMARC, DKIM, etc.

# load the common info about the domain
source "/etc/mailad/mailad.conf" || true

# DEBUG
if [ -z "$DOMAIN" ] ; then DOMAIN=$1; fi

# Basic vars Configuration
if [ -z "$SYSADMINS" ] ; then
    SYSADMINS="$MAILADMIN"
fi
SENDER="$MAILADMIN"
SUBJECT="DNS Configuration Report for $DOMAIN"
SWAKS_OPTS="--server localhost"
REPORT_FILE="/tmp/dns_report_$DOMAIN.txt"
SELECTOR=''
DKS=''
DKSC=''

# if DKIM_SIGNING active, check for the selector
if [ "ENABLE_DKIM_SIGN" == "yes" -o "ENABLE_DKIM_SIGN" == "Yes" ] ; then
    # enabled DKIM signing
    DKSC=yes
    
    # DKIM_DATA_FILE=$(ls /var/lib/amavis/dkim/${DOMAIN}*.txt)
    DKIM_DATA_FILE=$(ls /tmp/${DOMAIN}*.txt)
    if [ -f "$DKIM_DATA_FILE" ] ; then
        filename=$(basename "$DKIM_DATA_FILE")
        filename_no_ext="${filename%.txt}"
        SELECTOR="${filename_no_ext##*.}"
        DKS=yes
    fi
fi

# Check required tools
command -v dig &>/dev/null || { echo "Error: dig required but not found"; exit 1; }
#command -v swaks &>/dev/null || { echo "Error: swaks required but not found"; exit 1; }

# Create report
{
    echo "DNS CONFIG REPORT FOR: $DOMAIN"
    echo "Generated: $(date)"
    echo "======================================================"
    
    # Main DNS Servers
    echo -e "\n[MAIN DNS SERVERS]:"
    dig +short NS "$DOMAIN" | sort | sed 's/^/• /' > /tmp/NS
    if [ -z "$(cat /tmp/NS)" ] ; then
        echo "❌ Not found! can't find the main DNS servers for $DOMAIN"
    else
        cat /tmp/NS
    fi
    echo "Note: This is the authoritative DNS servers that controls the domain $DOMAIN"
    rm /tmp/NS
    
    # Main MX Servers
    echo -e "\n[MAIN MAIL SERVERS]:"
    dig +short MX "$DOMAIN" | awk '{print $2}' | sort | sed 's/^/• /' > /tmp/MX
    if [ -z "$(cat /tmp/MX)" ] ; then
        echo "❌ Not found! can't find the Mail servers for $DOMAIN"
    else
        cat /tmp/MX
    fi
    echo "Note: This are the server we use to deliver emails for the $DOMAIN domain from the outside world."
    rm /tmp/MX

    # Service configs
    echo -e "\n[SERVICE CONFIGS]:"
    for s in submission:587 imaps:993 ; do
        service=${s%%:*}
        port=${s##*:}
        RESULT=$(dig +short SRV "_${service}._tcp.$DOMAIN" | sort | sed 's/^/• /')

        # check if the service is configured
        if [ -z "$RESULT" ] ; then
            echo "⚠️  ${service} SRV record not found."
            echo "Recommended content: \"_${service}._tcp. 10 0 $port $service.$DOMAIN\""
        else
            echo "✅ service ${service} record found:"
            echo "$RESULT"
        fi
    done
    echo "This records are used by email clients for auto configuration. They are not required but a good practice."
    echo "See: https://www.cloudflare.com/learning/dns/dns-records/dns-srv-record/"

    # SPF Check
    echo -e "\n[SPF RECORD]:"
    SPF_RECORD=$(dig +short TXT "$DOMAIN" | grep -E '^"v=spf1')
    if [ -n "$SPF_RECORD" ]; then
        echo "✅ Found: $SPF_RECORD"
        echo "Recommended content: \"v=spf1 mx a -all\""
    else
        echo "❌ Not found!"
        echo "Action required: Create TXT record for $DOMAIN with SPF policy"
    fi
    echo "SPF Setup Guide: https://www.cloudflare.com/learning/dns/dns-records/dns-spf-record/"
    
    # DMARC Check
    echo -e "\n[DMARC RECORD]:"
    DMARC_RECORD=$(dig +short TXT "_dmarc.$DOMAIN" | grep -E '^"v=DMARC1')
    if [ -n "$DMARC_RECORD" ]; then
        echo "✅ Found: $DMARC_RECORD"
        echo "Recommended content: \"v=DMARC1; p=reject; adkim=s; aspf=s; rua=mailto:dmarc@$DOMAIN\""
    else
        echo "❌ Not found!"
        echo "Action required: Create TXT record for _dmarc.$DOMAIN"
    fi
    echo "DMARC Setup Guide: https://www.cloudflare.com/learning/dns/dns-records/dns-dmarc-record/"
    
    # DKIM Check
    echo -e "\n[DKIM RECORDS]:"
    if [ -z "$DKSC" ] ; then
        echo "⚠️  No DKIM signing configured on this setup. So, can't check for DKIM if external signing is used."
    fi
    
    # no selector, but why?
    if [ -z "$DKS" -a -n "$DKSC" ] ; then
        echo "⚠️  DKIM signing configured but NO DKIM key found on this setup. Please review the config and re-run a provision on this system ASAP!"
    fi

    # selector found
    if [ -z "$SELECTOR" -a "$DKS"] ; then
        # selector found
        RECORD=$(dig +short TXT "${SELECTOR}._domainkey.$DOMAIN" | grep -E '^"v=DKIM1')
        if [ -n "$RECORD" ]; then
            echo "✅ Found ($SELECTOR): $RECORD"
        else
            echo "❌ No DKIM records found using the provided selector"
            echo "Action required: Create TXT record for <selector>._domainkey.$DOMAIN"
        fi
    fi 
    echo "DKIM Setup Guide: https://www.cloudflare.com/learning/dns/dns-records/dns-dkim-record/"

    # Resources
    echo -e "\n[RESOURCES]"
    echo "• Test Tools:"
    echo "  - Mail-Tester: https://www.mail-tester.com/"
    echo "  - MXToolBox: https://mxtoolbox.com/emailhealth/"
    echo "  - Google Admin Tool: https://toolbox.googleapps.com/apps/checkmx/"
    
    echo -e "\nReport generated by MailAD config checker"
} > "$REPORT_FILE"

# Send email
cat $REPORT_FILE

#swaks --to "$RECIPIENT" \
#    --from "$SENDER" \
#    --header "Subject: $SUBJECT" \
#    --body "$REPORT_FILE" \
#    $SWAKS_OPTS

# Cleanup
#rm "$REPORT_FILE"
#echo "Report sent to $RECIPIENT"

