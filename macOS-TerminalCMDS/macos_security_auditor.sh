#!/bin/bash

# macOS Quick Security Configuration Auditor
# Purpose: Checks the status of key macOS security settings.

echo "macOS Quick Security Configuration Auditor"
echo "----------------------------------------"

print_status() {
    setting_name="$1"
    status_command_output="$2"
    # Basic interpretation, can be expanded
    if [[ "$status_command_output" == *"Enabled"* || "$status_command_output" == *"On"* || "$status_command_output" == *"1"*  || "$status_command_output" == *"active"* ]]; then
        interpreted_status="Enabled/Active"
    elif [[ "$status_command_output" == *"Disabled"* || "$status_command_output" == *"Off"* || "$status_command_output" == *"0"* ]]; then
        interpreted_status="Disabled/Inactive"
    else
        interpreted_status="Status unclear or needs manual check"
    fi
    printf "%-30s: %s (%s)\n" "$setting_name" "$interpreted_status" "$status_command_output"
}

echo ""
echo "Checking security settings..."
echo ""

# 1. Firewall Status
echo "Firewall Status:"
# Method 1: Using defaults (might require sudo for some global settings, but reading globalstate is often fine)
fw_globalstate=$(defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null)
if [[ "$fw_globalstate" == "1" ]]; then
    print_status "Application Firewall (ALF)" "Enabled (Allow signed/specific)"
elif [[ "$fw_globalstate" == "2" ]]; then
    print_status "Application Firewall (ALF)" "Enabled (Block all incoming)"
elif [[ "$fw_globalstate" == "0" ]]; then
    print_status "Application Firewall (ALF)" "Disabled"
else
    # Method 2: Using socketfilterfw (more reliable for current state)
    fw_status_socketfilterfw=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
    if [[ -n "$fw_status_socketfilterfw" ]]; then
         print_status "Application Firewall (socketfilterfw)" "$fw_status_socketfilterfw"
    else
        print_status "Application Firewall" "Could not determine status (try with sudo or check System Settings)"
    fi
fi
echo ""


# 2. FileVault (Full Disk Encryption) Status
echo "FileVault Status:"
fv_status=$(fdesetup status 2>/dev/null)
print_status "FileVault Encryption" "$fv_status"
echo ""

# 3. Gatekeeper Status
echo "Gatekeeper Status:"
# spctl --status can be a bit verbose, let's try to get a clearer picture
gk_assessment_status=$(spctl --status | grep "assessments" | awk '{print $2}')
if [[ "$gk_assessment_status" == "enabled" ]]; then
    print_status "Gatekeeper Assessments" "Enabled"
else
    print_status "Gatekeeper Assessments" "Disabled or Unknown ($gk_assessment_status)"
fi
# More detailed Gatekeeper policy (App Store and identified developers, or App Store only)
# This is harder to get directly via a simple command without parsing plists or using profiles.
# The 'spctl --status' is the primary indicator.
echo "   (Check System Settings > Privacy & Security > Security for specific download policy)"
echo ""

# 4. System Integrity Protection (SIP) Status
echo "System Integrity Protection (SIP) Status:"
sip_status=$(csrutil status 2>/dev/null)
print_status "System Integrity Protection" "$sip_status"
echo ""


echo "Security audit complete."
echo "Please review the statuses. For detailed configuration, refer to System Settings."

exit 0