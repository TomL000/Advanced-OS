#!/bin/bash

LOG="submission_log.txt"
SUBMISSIONS="submissions.txt"
LOGIN_LOG="login_log.txt"

declare -A attempts

# Allows the user to submit a PDF or DOCX file only, else returns invalid.
submit_file() {
    read -p "Enter filename: " file

    if [[ ! "$file" =~ \.(pdf|docx)$ ]]; then
        echo "Invalid file type!"
        return
    fi
# Check for if the file type is too large.
    size=$(stat -c%s "$file")
    if [ "$size" -gt 5242880 ]; then
        echo "File too large!"
        return
    fi

# Checks if this file has already been submitted by its MD5 hash.
    hash=$(md5sum "$file" | cut -d ' ' -f1)

    if grep -q "$hash" $SUBMISSIONS; then
        echo "Duplicate submission!"
        return
    fi

    echo "$file,$hash" >> $SUBMISSIONS
    echo "$(date) - Submitted $file" >> $LOG
}

# Another check for duplicated files via its MD5 hash.
check_duplicate() {
    read -p "Enter filename: " file
    hash=$(md5sum "$file" | cut -d ' ' -f1)

    if grep -q "$hash" $SUBMISSIONS; then
        echo "Already submitted"
    else
        echo "Not submitted"
    fi
}

# Lists all files on the system.
list_files() {
    cat $SUBMISSIONS
}

# Allows the user to log in, also logs the logins by the user with the appropriate time.
login_attempt() {
    read -p "Username: " user
    read -p "Password: " pass

    correct="admin123"

    now=$(date +%s)

    if [[ "$pass" != "$correct" ]]; then
        attempts[$user]=$((attempts[$user]+1))
        echo "Failed attempt"

        if [ "${attempts[$user]}" -ge 3 ]; then
            echo "Account locked!"
        fi
    else
        echo "Login successful"
        attempts[$user]=0
    fi

    echo "$(date) - Login attempt by $user" >> $LOGIN_LOG
}

# User Interface.
while true
do
    echo "--- Secure System ---"
    echo "1. Submit Assignment"
    echo "2. Check for Duplicates"
    echo "3. List of Submissions"
    echo "4. Login Attempts Log"
    echo "5. Exit"

    read choice

    case $choice in
        1) submit_file ;;
        2) check_duplicate ;;
        3) list_files ;;
        4) login_attempt ;;
        5) exit ;;
    esac
done