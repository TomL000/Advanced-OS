#!/bin/bash

QUEUE="job_queue.txt"
DONE="completed_jobs.txt"
LOG_FILE="scheduler_log.txt"

touch $QUEUE $DONE $LOG_FILE

# Much like task 1,  log_action echos the date whenever LOG_FILE is called.
log_action() {
    echo "$(date) - $1" >> $LOG_FILE
}

# Reads the Student ID, Job name, Execution time and Priority imputed by the user and stores it as a stubmitted job
submit_job() {
    read -r -p "Student ID: " sid
    read -r -p "Job Name: " job
    read -r -p "Execution Time: " time
    read -r -p "Priority (1-10): " pr

    echo "$sid,$job,$time,$pr" >> $QUEUE
    log_action "Submitted $job by Student: $sid"
}

# Shows all pending jobs found in queue after submitting them
pending_jobs() {
    cat $QUEUE
}

# Uses a round robin algorithm to complete one of the jobs with the student ID added on.
round_robin() {
    quantum=5
    temp="temp.txt"
    > $temp

    while IFS=, read -rsid job time pr
    do
        if [ "$time" -gt "$quantum" ]; then
            remaining=$((time - quantum))
            echo "$sid,$job,$remaining,$pr" >> $temp
        else
            echo "$sid,$job has been completed" >> $DONE
            log_action "Executed $job by the Student ID: $sid (RR)"
        fi
    done < $QUEUE

    mv $temp $QUEUE
}

# Uses a round priority scheduling to complete one of the jobs with the student ID added on.
priority_schedule() {
    sort -t, -k4 -nr $QUEUE | while IFS=, read -r sid job time pr
    do
        sleep 1
        echo "$sid,$job has been completed" >> $DONE
        log_action "Executed $job by the Student ID: $sid (Priority)"
    done

    > $QUEUE
}

# User Interface, reads imputted options to execute the different functions of the script. Very similar to task 1.
while true
do
    echo "--- Scheduler ---"
    echo "1. View Pending Jobs"
    echo "2. Submit a Job"
    echo "3. Process Queue: Round Robin"
    echo "4. Process Queue: Priority Scheduling"
    echo "5. View Completed Jobs"
    echo "6. Exit"

    read -r choice

    case $choice in
        1) pending_jobs ;;
        2) submit_job ;;
        3) round_robin ;;
        4) priority_schedule ;;
        5) cat $DONE ;;
        6) exit ;;
    esac
done
