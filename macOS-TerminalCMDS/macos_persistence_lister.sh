#!/bin/bash

# macOS Startup & Persistence Mechanisms Lister
# Purpose: Lists common persistence locations and items.

echo "macOS Startup & Persistence Mechanisms Lister"
echo "-------------------------------------------"

print_section_header() {
    echo ""
    echo "--- $1 ---"
}

# List LaunchAgents and LaunchDaemons directories
print_section_header "User LaunchAgents (~/Library/LaunchAgents)"
ls -la ~/Library/LaunchAgents 2>/dev/null || echo "Directory not found or no items."

print_section_header "Global LaunchAgents (/Library/LaunchAgents)"
ls -la /Library/LaunchAgents 2>/dev/null || echo "Directory not found or no items."

print_section_header "Global LaunchDaemons (/Library/LaunchDaemons)"
ls -la /Library/LaunchDaemons 2>/dev/null || echo "Directory not found or no items."

# System LaunchAgents and LaunchDaemons (less likely to be user-modified for malware, but good to be aware of)
# print_section_header "System LaunchAgents (/System/Library/LaunchAgents)"
# ls -la /System/Library/LaunchAgents 2>/dev/null || echo "Directory not found or no items."
# print_section_header "System LaunchDaemons (/System/Library/LaunchDaemons)"
# ls -la /System/Library/LaunchDaemons 2>/dev/null || echo "Directory not found or no items."

# List currently loaded user launchctl jobs
print_section_header "Currently Loaded User Launch Agents/Daemons (launchctl list for current user)"
launchctl list | grep -v 'com.apple' # Filter out most Apple default services for brevity
# For a full list without filtering: launchctl list

echo ""
echo "Note: For a complete list of system-wide daemons, you might need to run 'sudo launchctl list'."

# Optional: Pretty-print a specific plist file
echo ""
read -r -p "Do you want to view the contents of a specific .plist file? (y/N): " view_plist_choice

if [[ "$view_plist_choice" =~ ^[Yy]$ ]]; then
    read -r -p "Enter the full path to the .plist file: " plist_path
    if [[ -f "$plist_path" ]]; then
        print_section_header "Contents of ${plist_path}"
        plutil -p "$plist_path"
    else
        echo "Error: File not found at '${plist_path}'"
    fi
fi

echo ""
echo "Persistence check complete."
echo "Review the listed files and processes for any unrecognized or suspicious items."

exit 0