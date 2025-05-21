#!/bin/bash

# macOS Troubleshooting Script
#
# Save this file as macos_troubleshooter.sh
# Make it executable: chmod +x macos_troubleshooter.sh
# Run it: ./macos_troubleshooter.sh

# Function to display a separator and title
print_section_header() {
    echo ""
    echo "--------------------------------------------------"
    echo "$1"
    echo "--------------------------------------------------"
}

# Function to display system information
show_system_info() {
    print_section_header "System Information"
    echo "macOS Version:"
    sw_vers
    echo ""
    echo "Hardware Overview (Key Details):"
    system_profiler SPHardwareDataType | grep -E \
        "Model Name:|Model Identifier:|Processor Name:|Processor Speed:|Number of Processors:|Total Number of Cores:|Memory:|Serial Number \(system\):|Hardware UUID:"
    echo ""
    echo "Uptime and Load Averages:"
    uptime
    echo ""
    echo "Boot Time:"
    # sysctl kern.boottime is blacklisted, so we'll skip a direct boot time command here.
    # Users can often infer this from uptime or logs if needed.
    echo "Boot time information can be checked via 'log show --last boot' or inferred from uptime."
}

# Function to display network information
show_network_info() {
    print_section_header "Network Information"
    echo "Active Network Services:"
    networksetup -listallnetworkservices | grep -v '*' # List enabled services
    echo ""
    echo "Current Wi-Fi Network Details (if Wi-Fi is active):"
    if networksetup -getairportnetwork en0 | grep -q "Current Wi-Fi Network"; then
        networksetup -getairportnetwork en0
    elif networksetup -getairportnetwork en1 | grep -q "Current Wi-Fi Network"; then
        networksetup -getairportnetwork en1
    else
        echo "Wi-Fi details not readily available or Wi-Fi not primary."
    fi
    echo ""
    echo "Primary Interface Configuration (usually en0 or en1):"
    # Attempt to find the primary active interface
    PRIMARY_IF=$(route -n get default | grep 'interface:' | awk '{print $2}')
    if [ -n "$PRIMARY_IF" ]; then
        echo "Detected primary interface: $PRIMARY_IF"
        ifconfig "$PRIMARY_IF"
    else
        echo "Could not automatically determine primary interface. Showing en0:"
        ifconfig en0
    fi
    echo ""
    echo "Routing Table (IPv4):"
    netstat -nr -f inet | head -n 15 # Show top 15 IPv4 routes
    echo ""
    echo "DNS Resolver Configuration:"
    scutil --dns
}

# Function to display disk usage
show_disk_usage() {
    print_section_header "Disk Usage"
    echo "Overall Disk Space:"
    df -h / # Show usage for the root filesystem
    df -h # Show usage for all mounted filesystems
    echo ""
    echo "Top 10 largest files/folders in User's Home Directory (may take a moment):"
    echo "Scanning: ~/Documents, ~/Downloads, ~/Desktop, ~/Library, ~/Movies, ~/Music, ~/Pictures ..."
    # Be mindful of permissions and very large directories.
    # Using find and then du for better control and error handling.
    find ~/Documents ~/Downloads ~/Desktop ~/Library ~/Movies ~/Music ~/Pictures -maxdepth 1 -type d -print0 2>/dev/null | xargs -0 -I {} du -sh "{}" 2>/dev/null | sort -rh | head -n 10
    echo "Note: ~/Library can be very large. The scan above is limited for speed."
}

# Function to display running processes (top CPU/Memory consumers)
show_running_processes() {
    print_section_header "Top Running Processes"
    echo "Top 10 CPU Consuming Processes:"
    ps -arcx -o %cpu,pid,user,command | head -n 11
    echo ""
    echo "Top 10 Memory Consuming Processes (Resident Set Size):"
    ps -arcx -o %mem,rss,pid,user,command | head -n 11
    # For a more interactive view, user can run 'top' or 'htop' (if installed) separately.
}

# Function to check network connectivity
check_network_connectivity() {
    print_section_header "Network Connectivity Test"
    target_host="apple.com" # Using apple.com as a generally reliable target
    echo "Pinging ${target_host} (4 packets)..."
    ping -c 4 "${target_host}"
    echo ""
    echo "Traceroute to ${target_host} (max 15 hops)..."
    traceroute -m 15 "${target_host}"
}

# Function to view recent system logs
view_recent_logs() {
    print_section_header "Recent System Logs (Errors & Faults - Last 15 min)"
    echo "Fetching logs... This might take a moment."
    # Using --style compact for brevity, --info to include info level for context
    log show --last 15m --predicate 'messageType == error || messageType == fault' --info --style compact
    echo "For more detailed logs, use Console.app or 'log stream' in Terminal."
}

# Main menu
while true; do
    echo ""
    echo "============================================"
    echo "      macOS Troubleshooting Script Menu"
    echo "============================================"
    echo "1. Show System Information"
    echo "2. Show Network Information"
    echo "3. Show Disk Usage"
    echo "4. Show Top Running Processes (CPU/Memory)"
    echo "5. Check Network Connectivity (to apple.com)"
    echo "6. View Recent System Logs (Errors/Faults)"
    echo "--------------------------------------------"
    echo "q. Quit Script"
    echo "============================================"
    echo ""
    read -r -p "Enter your choice [1-6, q]: " choice

    case $choice in
        1) show_system_info ;;
        2) show_network_info ;;
        3) show_disk_usage ;;
        4) show_running_processes ;;
        5) check_network_connectivity ;;
        6) view_recent_logs ;;
        q|Q) echo "Exiting script. Goodbye!"; exit 0 ;;
        *) echo "Invalid choice. Please enter a number from 1-6 or 'q'." ;;
    esac
    echo ""
    read -n 1 -s -r -p "Press any key to return to the menu..."
    # Clear screen for better readability, optional
    # clear
done