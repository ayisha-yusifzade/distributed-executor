#!/bin/bash

job_id=$1
cmd=$2

if [ -z "$cmd" ]; then
    echo "[WORKER] ERROR: empty command"
    exit 1
fi

echo "[WORKER] Job $job_id running: $cmd"

# SAFE EXECUTION
output=$(bash -c "$cmd" 2>&1)
status=$?

if [ $status -ne 0 ]; then
    echo "[WORKER] FAILED"
    echo "$output"
    exit 1
fi

echo "[WORKER] RESULT:"
echo "$output"

exit 0
