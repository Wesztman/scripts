#!/bin/bash
# Text files to monitor
files=("file1.txt" "file2.txt" "file3.txt" "file4.txt" "file5.txt" "file6.txt")

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'  # reset

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
start_time=$(date +%s%3N) # milliseconds since epoch
trap "echo -e '\n'; tput cnorm; exit" INT  # cleanup on Ctrl+C
tput civis  # hide cursor

# Clear screen once
clear

# Draw simple box
echo -e "┌───────────────────────────────────────────────────────────┐"
echo -e "│ ${GREEN}STATUS${NC}                                            │"
echo -e "└───────────────────────────────────────────────────────────┘"

while true; do
    # Calculate elapsed time
    now=$(date +%s%3N)
    elapsed=$((now - start_time))
    sec=$((elapsed / 1000))
    min=$((sec / 60))
    sec=$((sec % 60))

    # Format status line to match screenshot
    status_line="${YELLOW}Time: $(printf "%02d:%02d" "$min" "$sec")${NC} "

    # Add file indicators
    for i in "${!files[@]}"; do
        file_path="$SCRIPT_DIR/${files[i]}"
        val=$(cat "$file_path" 2>/dev/null | tr -d '[:space:]')
        file_label="File$((i+1))"

        if [[ "$val" == "true" ]]; then
            status_line+="${GREEN}■ ${file_label} ${NC}"
        else
            status_line+="${RED}■ ${file_label} ${NC}"
        fi
    done

    # Print single line, overwriting previous
    echo -ne "\r$status_line"

    # Sleep for 200ms
    sleep 0.2
done