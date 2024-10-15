#!/bin/bash

echo " ============================================================================="
echo "  NMAP Automation Script"
echo " ============================================================================="
echo "  Description : A script to automate NMAP scans with customizable options."
echo "  Author      : [Lupoxoox]"
echo "  Version     : 1.0"
echo "  Created     : [1-10-24]"
echo "  Last Update : [15-10-24]"
echo "  License     : MIT License"
echo " ============================================================================="
echo "  Usage:"
echo "  This script allows users to run predefined or custom NMAP scans. It includes:"
echo "   - Performance tuning options"
echo "   - Saving scan results in various formats"
echo "   - Special scan modes with error handling for user inputs"
echo " ============================================================================="
echo "  Notes:"
echo "  - Requires root privileges to execute."
echo "  - Results can be saved in a folder named after the chosen filename."
echo " ============================================================================="




# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIWhite='\033[1;97m'      # White
NC='\033[0m'              # No Color

# function to alternate color 
function colored_print {
    local index=$1
    local text=$2

    
    if (( index % 3 == 0 )); then
        echo -e "${BIGreen}$text${NC}"
    elif (( index % 3 == 1 )); then
        echo -e "${BIWhite}$text${NC}"
    else
        echo -e "${BIRed}$text${NC}"
    fi
}

            ######################### THIS IS THE OPTION LIST ######################### 
performance=(
    "--max-retries <num> Sets the number of retries for scans of specific ports."
    "--stats-every=5s Displays scan's status every 5 seconds."
    "-vv Displays verbose output during the scan."
    "--initial-rtt-timeout 50ms Sets the specified time value as initial RTT timeout."
    "--max-rtt-timeout" "100 Sets the specified time value as maximum RTT timeout."
    "--min-rate 300 Sets the number of packets that will be sent simultaneously."
    "-T 2 Specifies the specific timing template."
)

options=(
    "-F Scans top 100 ports."
    "-sT Connect()"
    "-sA Performs an TCP ACK-Scan."
    "-sS (TCP SYN scan)"
    "-sN disable port scanning"
    "-sU (UDP scan)"
    "-sV Scans the discovered services for their versions."
    "-sC Perform a Script Scan with scripts that are categorized as default"
    "-n (No DNS resolution)"
    "-A (Aggressive scan with OS and version detection)"
    "-O (OS detection)"
    "--top-ports 100 (Scan top 100 ports)"
    "-p- (Scan all ports)"
    "--script vuln (Vulnerability scan)"
    "--traceroute (Traceroute)"
    "-Pn  Disables ICMP Echo Requests(No ping)"
    "-PE Performs the ping scan by using ICMP Echo Requests against the target."
    "--packet-trace Shows all packets sent and received."
    "--reason Displays the reason for a specific result."
    "--disable-arp- Disables ARP Ping Requests."
    
)

special=(
    "-T4 (Faster execution)"
    "--top-ports= Scans the specified top ports that have been defined as most<num>frequent."
    "-p22-110 Scan all ports between 22 and 110."
    "-D RND:5 Sets the number of random Decoys that will be used to scan the target."
    "-e Specifies the network interface that is used for the scan."
    "-S 10.10.10.200 Specifies the source IP address for the scan."
    "-g Specifies the source port for the scan."
    "--dns-server DNS resolution is performed by using a specified name server."
)

save=(
    "-oA Stores the results in all available formats starting with the name of filename filename".
    "-oN Stores the results in normal format with the name filename".
    "-oG Stores the results in grepable format with the name of filename".
    "-oX Stores the results in XML format with the name of filename".
)

        ########################## THIS IS THE FUNCTION ################################
        ########################      root cheking        ##############################
# Function to check if the user is root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root."
        exit 1
    fi
}

# Call to the function
check_root

# The rest of the script goes here
echo "If you see this message, you have root permissions!"


##########################   FUNCTION SPECIAL   ################################
function Special {
    # Define options
    special=("Stealth Level (0-5)" "Top Ports" "Port Range" "Random Decoy" "Network Interface" "Source Port")

    # Show options
    for i in "${!special[@]}"; do
        colored_print $i "$((i+1))) ${special[$i]}"
    done

    read -p "Enter your choices: " -a spe

    spec=""

    # Verify input and build string
    for selection in "${spe[@]}" ; do
         case $selection in
         1) 
            # Stealth level
            while true; do
                read -p "Select from 0 stealth to 5 insane: " nrs 
                if [[ "$nrs" =~ ^[0-5]$ ]]; then
                    spec+="-T$nrs " 
                    break
                else
                    echo "Error: please enter a valid number between 0 and 5."
                fi
            done
            ;;
         2) 
            # Top ports
            while true; do
                read -p "--top-ports= " tp
                if [[ "$tp" =~ ^[0-9]+$ ]]; then
                    spec+="--top-ports=$tp " 
                    break
                else
                    echo "Error: please enter a valid number."
                fi
            done
            ;;
         3) 
            # Port range
            while true; do
                read -p "Select a port range (e.g., 20-80): " rangep
                if [[ "$rangep" =~ ^[0-9]+-[0-9]+$ ]]; then
                    spec+=" -p$rangep " 
                    break
                else
                    echo "Error: please enter a valid range (e.g., 20-80)."
                fi
            done
            ;;
         4) 
            # Random decoy
            while true; do
                read -p "Select number for random decoy: " rnd
                if [[ "$rnd" =~ ^[0-9]+$ ]]; then
                    spec+=" -D RND:$rnd "
                    break
                else
                    echo "Error: please enter a valid number."
                fi
            done
            ;;
         5) 
            # Network interface
            ifconfig
            read -p "Specify the network interface: " neti
             
            if [[ -z "$neti" ]]; then
                echo "No option selected."
                break
            else
                spec+=" -e $neti "
            fi
            ;;
         6) 
            # Source port
            while true; do
                read -p "-g Specify the source port for the scan: " sp
                if [[ "$sp" =~ ^[0-9]+$ ]]; then
                    spec+=" -g $sp " 
                    break
                else
                    echo "Error: please enter a valid number."
                fi
            done
            ;;
         *) 
            # Error handler for invalid selection
            echo "Error: invalid choice. Please try again."
            ;;
         esac
    done
}

######################### FUNCTION PERFORMANCE ##########################

function performances {
    for i in "${!performance[@]}"; do
        colored_print $i "$((i+1))) ${performance[$i]}"
    done

    read -p "Enter your choices: " -a sel
    
    perf=""
    for selection in "${sel[@]}" ; do
        case $selection in
        1) 
            while true; do
                read -p "--max-retries num: " nr 
                if [[ "$nr" =~ ^[0-9]+$ ]]; then
                    perf+=" --max-retries $nr" 
                    break  # Exit the loop if the input is valid
                else
                    echo "Error: please enter a valid number for --max-retries."
                fi
            done
            ;;
        2) 
            while true; do
                read -p "--stats-every= num (in seconds): " ns
                if [[ "$ns" =~ ^[0-9]+$ ]]; then
                    perf+=" --stats-every=${ns}s "
                    break
                else
                    echo "Error: please enter a valid number in seconds."
                fi
            done
            ;;
        3) 
            perf+=" -v "  # No input required
            ;;
        4) 
            while true; do
                read -p "--initial-rtt-timeout num (ms): " nirtt
                if [[ "$nirtt" =~ ^[0-9]+$ ]]; then
                    perf+=" --initial-rtt-timeout ${nirtt}ms "
                    break
                else
                    echo "Error: please enter a valid number in ms."
                fi
            done
            ;;
        5) 
            while true; do
                read -p "--max-rtt-timeout num (ms): " nmrtt
                if [[ "$nmrtt" =~ ^[0-9]+$ ]]; then
                    perf+=" --max-rtt-timeout ${nmrtt}ms "
                    break
                else
                    echo "Error: please enter a valid number in ms."
                fi
            done
            ;;
        6) 
            while true; do
                read -p "--min-rate num: " nminrt
                if [[ "$nminrt" =~ ^[0-9]+$ ]]; then
                    perf+=" --min-rate $nminrt "
                    break
                else
                    echo "Error: please enter a valid number for --min-rate."
                fi
            done
            ;;
        *)
            echo "Error: invalid option ($selection)."
            ;;
        esac
    done
}
################################### FUNCTION OPTION ############################

function option {
    echo "Select one or more options (e.g., 1 3 5) or press enter for no options:"
    for i in "${!options[@]}"; do
        colored_print $i "$((i+1))) ${options[$i]}"
    done

    # Read the user's choices
    read -p "Enter your choices: " choices

    while true; do
        read -p "Enter the target (e.g., 192.168.1.0/24): " target
        if [[ $target =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]+)?$ ]]; then
            break  # Exit the loop if the target is valid
        else
            echo "Error: please enter a valid IP address or range (e.g., 192.168.1.0/24)."
        fi
    done

    selected_options=""

    # Check if the user entered any choices
    if [[ -z "$choices" ]]; then
        echo "No options selected."
    else
        # Loop through the choices
        for choice in $choices; do
            # Check if the choice is a valid number
            if [[ $choice =~ ^[0-9]+$ ]] && (( choice > 0 && choice <= ${#options[@]} )); then
                selected_options+=" ${options[$((choice-1))]%% *}"  # Take only the option, without description
            else
                echo "Invalid choice: $choice"
                option
            fi
        done
    fi
}

################################ FUNCTION SAVEFILE #############################
function savefile {
    # Show save options
    for i in "${!save[@]}"; do
        colored_print $i "$((i+1))) ${save[$i]}"
    done

    # Ask for the filename
    read -p "Choose the filename (this will also be the folder name): " filename

    # Ensure the filename is not empty
    while [[ -z "$filename" ]]; do
        echo "Error: filename cannot be empty."
        read -p "Choose the filename: " filename
    done

    # Create a directory with the filename (if it doesn't already exist)
    if [ ! -d "$filename" ]; then
        mkdir "$filename"
        echo "Directory '$filename' created successfully."
    else
        echo "Directory '$filename' already exists."
    fi

    # Ask the user to select save options
    read -p "Select the file type (e.g., 1 2 for multiple options): " sc

    save_option=""

    # Check if the user selected any options
    if [[ -z "$sc" ]]; then
        echo "No save options selected."
    else
        # Loop through the selected save options
        for s in $sc; do
            if [[ $s =~ ^[0-9]+$ ]] && (( s > 0 && s <= ${#save[@]} )); then
                save_option+=" ${save[$((s-1))]%% *} $filename/$filename"
            else
                echo "Invalid choice: $s"
            fi
        done
    fi

    # Build the final command
    commands="nmap $target $selected_options $spec $perf $save_option"

    # Show the generated command
    echo "Generated command: $commands"

    # Ask for confirmation to run the command
    read -p "Do you want to run the command? (y/n): " confirm
    if [[ $confirm == "y" ]]; then
        eval $commands
    else
        echo "Command canceled."
    fi
}

################################## FUNCTION MENU #################################
function menu {
    echo  -e "${BIWhite}1) predefined menu"
    echo  -e "${BIGreen}2) custom"

    read -p "Menu choice: " menu

    case $menu in 
        1) predefined ;;
        2) all ;;
    esac
}
################### GENERAL FUNCTION ################ MAIN LOOP #################

function all {
    echo "
    GENERAL OPTION
    "
    option

    echo "
    PERFORMANCE
    "
    performances

    echo "
    SPECIAL SELECTION
    "
    Special

    read -p "Do you want to save to a file? (y/n): " s

    if [[ $s == "y" ]]; then
        savefile
    else
        command="nmap $target $selected_options $spec $perf"
        echo "Generated command: $command"

        read -p "Do you want to execute the command? (y/n): " confirm
        if [[ $confirm == "y" ]]; then
            eval $command
        else
            echo "Command canceled."
        fi
    fi
}

################### PREDEFINED MENU ###################

function predefined {
   while true; do
        read -p "Enter the target (e.g., 192.168.1.0/24): " target
        if [[ $target =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]+)?$ ]]; then
            break  # Exit the loop if the target is valid
        else
            echo "Error: please enter a valid IP address or range (e.g., 192.168.1.0/24)."
        fi
    done


    echo -e "${BIGreen}Select a predefined scan:${NC}"
    echo -e "${BIWhite}1) Fast Scan"
    echo -e "${BIRed}2) Version & OS Scan"
    echo -e "${BIGreen}3) Stealth Scan"
    echo -e "${BIWhite}4) Aggressive Scan"
    echo -e "${BIRed}5) SMB Scan"
    echo -e "${BIGreen}6) FTP Scan"
    echo -e "${BIWhite}7) Vulnerability Scan"
    
    read -p "Enter the number of the desired scan: " scan_choice
    case $scan_choice in
        1) selected_options="-F";;
        2) selected_options="-sV -O";;
        3) selected_options="-sS";;
        4) selected_options="-A";;
        5) selected_options="--script smb-enum-shares,smb-enum-users";;
        6) selected_options="--script ftp-anon,ftp-bounce";;
        7) selected_options="--script vuln";;
        *) 
            echo -e "${BIRed}Invalid choice.${NC}"
            exit 1
            ;;
    esac
    read -p "Do you want to save to a file? (y/n): " s

    if [[ $s == "y" ]]; then
        savefile
    else
    nmap $selected_options "$target"
    fi
}

menu