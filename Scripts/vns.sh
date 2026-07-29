#!/bin/bash
# ==============================================================================
# Arch Router vnStat Segmented Dashboard Tool
# ==============================================================================

# Ensure vnstat is installed
if ! command -v vnstat &> /dev/null; then
    echo "Error: vnstat is not installed. Run 'sudo pacman -S vnstat' first."
    exit 1
fi

# Shortcut: If an interface argument is passed directly (e.g., ./vns.sh tun0), 
# launch the live second-by-second view immediately.
if [ ! -z "$1" ]; then
    echo "Launching live second-by-second traffic monitor for interface: $1..."
    echo "Press [Ctrl + C] to exit back to terminal."
    sleep 1
    vnstat -i "$1" -l
    exit 0
fi

# --- STEP 1: SELECT TARGET INTERFACE ---
select_interface() {
    clear
    echo "=================================================================="
    echo "                 SELECT NETWORK INTERFACE TARGET                  "
    echo "=================================================================="
    echo " 1) WAN  (Motherboard ISP Port)"
    echo " 2) LAN  (PCIe Internal Core Network)"
    echo " 3) TUN0 (Primary Secure VPN Tunnel)"
    echo " 4) ALL  (Global Summary / System-wide)"
    echo " q) Exit Tool"
    echo "=================================================================="
    echo -n "Select target interface [1-4 or q]: "
    read -r int_choice

    case "$int_choice" in
        1) TARGET_IF="wan";;
        2) TARGET_IF="lan";;
        3) TARGET_IF="tun0";;
        4) TARGET_IF="all";;
        q|Q) exit 0;;
        *) 
            echo "Invalid selection."
            sleep 1
            select_interface
            ;;
    esac
}

# --- STEP 2: SELECT ACTION ON TARGET ---
show_report_menu() {
    clear
    echo "=================================================================="
    echo "   REPORTS FOR INTERFACE TARGET: [ ${TARGET_IF^^} ]               "
    echo "=================================================================="
    echo " 1) Live Traffic Monitor (Updates second-by-second)"
    echo " 2) Hourly Breakdown Bar Graph (Last 24 Hours)"
    echo " 3) Daily Traffic Totals (Last 30 Days)"
    echo " 4) Monthly Traffic Summary"
    echo " 5) Yearly Traffic Summary"
    echo " 6) Top 10 All-Time Highest Traffic Days"
    echo " 7) View Short Database Summary View"
    echo " 8) Force Database Update Now"
    echo " 9) View List of Monitored Database Interfaces"
    echo " b) Back to Interface Selection"
    echo " q) Exit Dashboard"
    echo "=================================================================="
    echo -n "Select an engineering report [1-9, b or q]: "
}

# Core Logic Loop
while true; do
    # Select interface if none is picked yet
    if [ -z "$TARGET_IF" ]; then
        select_interface
    fi

    show_report_menu
    read -r choice
    echo ""

    # Set up interface flags for vnstat parameters
    if [ "$TARGET_IF" = "all" ]; then
        IF_FLAG=""
    else
        IF_FLAG="-i $TARGET_IF"
    fi

    case "$choice" in
        1)
            echo "Monitoring target data... Press [Ctrl + C] to stop."
            sleep 1
            vnstat $IF_FLAG -l
            ;;
        2)
            vnstat $IF_FLAG -h
            echo -n "Press Enter to return..."; read -r
            ;;
        3)
            vnstat $IF_FLAG -d
            echo -n "Press Enter to return..."; read -r
            ;;
        4)
            vnstat $IF_FLAG -m
            echo -n "Press Enter to return..."; read -r
            ;;
        5)
            vnstat $IF_FLAG -y
            echo -n "Press Enter to return..."; read -r
            ;;
        6)
            vnstat $IF_FLAG -t
            echo -n "Press Enter to return..."; read -r
            ;;
        7)
            # Matched to native '-s' short flag from your longhelp
            vnstat $IF_FLAG -s
            echo -n "Press Enter to return..."; read -r
            ;;
        8)
            echo "Forcing instant database commit..."
            vnstat -u
            echo "Database updated."
            sleep 1
            ;;
        9)
            # Confirmed exact match from your terminal longhelp output
            vnstat --dbiflist
            echo -n "Press Enter to return..."; read -r
            ;;
        b|B)
            TARGET_IF=""
            ;;
        q|Q)
            echo "Exiting metrics engine panel."
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose a valid metric action."
            sleep 1
            ;;
    esac
done
