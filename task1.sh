#!/bin/bash

# The "!/bin/bash" is what lets the terminal read the bash code.


LOG_FILE="system_monitor_log.txt"
ARCHIVE_LOG="ArchiveLogs"

# Echos the date "year, month and day" as well as the time "hour, month and second" where "log_action" is called in the code.
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Shows the CPU and Memory usage in a a grid to be easily read by the user. Also provides the log_action
show_usage() {
    echo "CPU & Memory Usage:"
    top -b -n1 | head -5
    log_action "Viewed system usage"
}

# Echos the top 10 processes that consume the most memory to the user. Also provides the log_action
top_processes() {
    echo "Top 10 memory consuming processes:"
    ps -eo pid,user,%cpu,%mem --sort=-%mem | head -11
    log_action "Viewed top processes"
}

# Simple kill process, first reading what process the user wants to kill via their PID.
kill_process() {
    read -r -p "Enter the PID you wish to terminate: " pid

    # Prevents killing critical processes that may corrupt the system.
    if [ "$pid" -le 100 ]; then
        echo "Cannot terminate a critical system process! Please try something else."
        return
    fi

# Confirms if the user wants to kill the process before completely terminating it. Also provides the log_action
    read -r -p "Are you sure you want to kill this process? (Y/N): " confirm
    if [[ "$confirm" = "Y" || "$confirm" = "y" ]]; then
        kill -9 "$pid" && echo "Process terminated"
        log_action "Killed process PID $pid"
    fi
}

# Disk inspection command that asks for the directed the user wants before checking it. Also provides the log_action
disk_inspection() {
    read -r -p "Please enter your directory path: " dir
    du -sh "$dir"
    log_action "Checked disk usage for $dir"
}

# Archival script that zips the designationed file into a ".gz" file type and provides the date and time for when it was archived.
archive_logs() {
    mkdir -p $ARCHIVE_LOG

    find . -type f -name "*.log" -size +50M | while read -r file
    do
        timestamp=$(date +%Y%m%d%H%M%S)
        gzip -c "$file" > "$ARCHIVE_LOG/$(basename "$file")_$timestamp.gz"
        echo "Archived $file"
        log_action "Archived $file"
    done

# IN THE CASE THE FILE EXCEEDS 1GB, the file will not be archived.
    size=$(du -sm $ARCHIVE_LOG | cut -f1)
    if [ "$size" -gt 1024 ]; then
        echo "Warning: The Archieve logs exceeds 1GB! Please try again."
    fi
}

# Allows the user to exit the script with a Y/N answer. 
exit_system() {
    read -r -p "Confirm exit (Y/N): " confirm
    if [[ "$confirm" = "Y" || "$confirm" = "y" ]]; then
        echo "Bye!"
        exit 0
    fi
}

# Displays a UI that echoes all the selections the user can make and reads their choice.
while true
do
    echo "---- System Admin Tool ----"
    echo "1. Show the CPU & Memory Usage"
    echo "2. Show the Top Processes"
    echo "3. Kill a Process"
    echo "4. Disk Usage Inspection"
    echo "5. Archival Logs"
    echo "6. Exit"

    read -r -p "Choose option: " choice

# Aligns whatever choice the user made with its designated number to the function.
    case $choice in
        1) show_usage ;;
        2) top_processes ;;
        3) kill_process ;;
        4) disk_inspection ;;
        5) archive_logs ;;
        6) exit_system ;;
        *) echo "ERROR: Invalid option, please enter a number 1-6." ;;
    esac
done