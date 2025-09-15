#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'  # reset

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

start_time=$(date +%s%3N) # milliseconds since epoch
trap "echo -e '\n'; tput cnorm; exit" INT  # cleanup on Ctrl+C
tput civis  # hide cursor

# Parse configuration file
parse_config() {
    # Initialize arrays
    declare -ga check_indices=()
    declare -ga check_names=()
    declare -ga check_commands=()

    # Simple parsing using grep and sed
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*index:[[:space:]]*([0-9]+) ]]; then
            index="${BASH_REMATCH[1]}"
            name=$(grep -A3 "^[[:space:]]*- index: $index" "$1" | grep "name:" | sed -E 's/.*name:[[:space:]]*"([^"]*)".*/\1/')
            command=$(grep -A3 "^[[:space:]]*- index: $index" "$1" | grep "command:" | sed -E 's/.*command:[[:space:]]*"([^"]*)".*/\1/')

            if [[ -n "$index" && -n "$name" && -n "$command" ]]; then
                check_indices+=("$index")
                check_names+=("$name")
                check_commands+=("$command")
            fi
        fi
    done < <(grep -E "^[[:space:]]*-[[:space:]]*index:" "$1")
}

# Load the configuration
parse_config "$CONFIG_FILE"

while true; do
    # Clear screen each iteration for a clean display
    clear

    # Draw simple box
    echo -e "┌──────────────────────┐"
    echo -e "│        ${YELLOW}STATUS${NC}        │"
    echo -e "└──────────────────────┘"

    # Calculate elapsed time
    now=$(date +%s%3N)
    elapsed=$((now - start_time))
    sec=$((elapsed / 1000))
    min=$((sec / 60))
    sec=$((sec % 60))

    # Format time display
    time_display="${YELLOW}$(printf "%02d:%02d" "$min" "$sec")${NC}"

    # Status line with time at the end
    status_line=""

    # Process each check
    for i in "${!check_indices[@]}"; do
        # Execute the command in the context of the script directory
        (cd "$SCRIPT_DIR" && bash -c "${check_commands[i]}")
        result=$?

        if [[ $result -eq 0 ]]; then
            status_line+="${GREEN}■ ${check_names[i]}${NC} "
        else
            status_line+="${RED}■ ${check_names[i]}${NC} "
        fi
    done

    # Print the status line and time on separate lines for simpler formatting
    echo -e "\n$status_line"
    echo -e "\n${time_display}"

    # Sleep briefly
    sleep 0.1
done