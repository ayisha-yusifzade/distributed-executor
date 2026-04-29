#!/bin/bash
# worker.sh - Base64 Decoding and Execution Engine

# Arguments received from runner.sh
job_id=$1
encoded_cmd=$2

# Decode the command back to its original string
cmd=$(echo "$encoded_cmd" | base64 --decode)

if [ -z "$cmd" ]; then
    echo "[WORKER] ERROR: Received empty command"
    exit 1
fi

echo "[WORKER] Executing Job $job_id: $cmd"

# Execute the decoded command using eval to handle logical operators (&&, ||, ;)
output=$(eval "$cmd" 2>&1)
status=$?

if [ $status -ne 0 ]; then
    echo "[WORKER] FAILED with status $status"
    echo "$output"
    exit $status
fi

echo "[WORKER] SUCCESS"
echo "$output"
exit 0
