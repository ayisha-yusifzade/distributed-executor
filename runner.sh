#!/bin/bash

# Prevent the script from exiting prematurely on errors
set +e

echo "[SYSTEM] Distributed Orchestrator (Final V9 - Base64 Robust Mode)"

# Configuration
DB="jobs.db"
MAX_RETRY=3

# Logging helper
log() { echo "[$(date +%H:%M:%S)] $1"; }

# Node selection logic
get_least_loaded_node() {
    # Defaulting to node1 (localhost) for local execution
    echo "node1"
}

# Main processing loop
while true; do
    # 1. Fetch the next queued job ID
    job_id=$(sqlite3 "$DB" "SELECT id FROM jobs WHERE status='QUEUED' ORDER BY id ASC LIMIT 1;")
    
    if [ -z "$job_id" ]; then
        log "No QUEUED jobs left in database"
        break
    fi

    # 2. Fetch the full command string for the specific ID
    cmd=$(sqlite3 "$DB" "SELECT cmd FROM jobs WHERE id=$job_id;")
    
    # 3. Base64 Encode the command to ensure safe transmission over SSH
    # This prevents special characters like &&, |, or quotes from breaking the shell
    encoded_cmd=$(echo -n "$cmd" | base64 -w 0)
    
    host=$(get_least_loaded_node)
    log "DISPATCH job $job_id → $host"
    
    # Mark job as RUNNING
    sqlite3 "$DB" "UPDATE jobs SET status='RUNNING', host='$host' WHERE id=$job_id;"
    
    # Execution timer
    start=$(date +%s%3N)

    # 4. Transmit encoded payload to worker.sh via SSH
    output=$(ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no \
        "$host" "bash -s" -- "$job_id" "$encoded_cmd" < worker.sh 2>&1)
    
    status=$?
    end=$(date +%s%3N)
    duration=$((end-start))
    
    # Escape single quotes in output for SQL safety
    safe_output=$(printf "%s" "$output" | sed "s/'/''/g")

    # 5. Retry and Status Management
    retry_current=$(sqlite3 "$DB" "SELECT retry FROM jobs WHERE id=$job_id;")
    retry_current=${retry_current:-0}
    
    if [ $status -eq 0 ]; then
        state="SUCCESS"
        new_retry=$retry_current
        log "SUCCESS job $job_id"
    else
        new_retry=$((retry_current + 1))
        if [ $new_retry -lt $MAX_RETRY ]; then
            log "RETRY job $job_id attempt $new_retry"
            sqlite3 "$DB" "UPDATE jobs SET status='QUEUED', retry=$new_retry WHERE id=$job_id;"
            continue
        else
            state="FAIL"
            log "FAIL FINAL job $job_id"
        fi
    fi

    # Final Database Update
    sqlite3 "$DB" "UPDATE jobs SET status='$state', output='$safe_output', duration=$duration, retry=$new_retry WHERE id=$job_id;"
done

log "SYSTEM DONE"
