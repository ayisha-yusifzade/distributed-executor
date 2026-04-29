#!/bin/bash

set +e  # crash etməsin, system davam etsin

echo "[SYSTEM] Distributed Orchestrator (FINAL COMPATIBLE MODE)"

DB="jobs.db"
MAX_RETRY=3
DEBUG=${DEBUG:-0}

log() {
    echo "[$(date +%H:%M:%S)] $1"
}

# =========================
# LOAD BALANCER (SAFE + REAL)
# =========================
get_load() {
    host=$1

    load=$(ssh -o ConnectTimeout=2 -o BatchMode=yes -o StrictHostKeyChecking=no \
        "$host" "cat /proc/loadavg 2>/dev/null | awk '{print \$1}'" 2>/dev/null)

    echo "${load:-999}"
}

get_least_loaded_node() {

node1=$(get_load node1)
node2=$(get_load node2)
node3=$(get_load node3)

[ "$DEBUG" -eq 1 ] && log "LOAD node1=$node1 node2=$node2 node3=$node3"

min_node="node1"
min_load=$node1

for n in node2 node3; do
    load=$(eval echo \$$n)

    # safe compare
    res=$(awk "BEGIN {print ($load < $min_load)}")

    if [ "$res" -eq 1 ]; then
        min_load=$load
        min_node=$n
    fi
done

echo "$min_node"
}

# =========================
# MAIN LOOP
# =========================
while true; do

JOB=$(sqlite3 "$DB" "SELECT id,cmd FROM jobs WHERE status='QUEUED' ORDER BY id ASC LIMIT 1;")

if [ -z "$JOB" ]; then
    log "No QUEUED jobs left"
    break
fi

job_id=$(echo "$JOB" | cut -d'|' -f1)
cmd=$(echo "$JOB" | cut -d'|' -f2)

host=$(get_least_loaded_node)

log "DISPATCH job $job_id → $host"

sqlite3 "$DB" "UPDATE jobs SET status='RUNNING', host='$host' WHERE id=$job_id;"

start=$(date +%s%3N)

# =========================
# SAFE SSH EXECUTION (IMPORTANT FIX)
# =========================
output=$(ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
    "$host" "bash -s '$job_id' '$cmd'" < worker.sh 2>&1)

status=$?

end=$(date +%s%3N)
duration=$((end-start))

# =========================
# SAFE OUTPUT (SQL SAFE)
# =========================
safe_output=$(printf "%s" "$output" | sed "s/'/''/g")

# =========================
# RETRY SYSTEM
# =========================
retry=$(sqlite3 "$DB" "SELECT retry FROM jobs WHERE id=$job_id;" 2>/dev/null)
retry=${retry:-0}
retry=$((retry+1))

if [ $status -ne 0 ]; then

    if [ $retry -lt $MAX_RETRY ]; then

        log "RETRY job $job_id attempt $retry"

        sqlite3 "$DB" "UPDATE jobs SET status='QUEUED', retry=$retry WHERE id=$job_id;"

        continue
    else
        state="FAIL"
        log "FAIL FINAL job $job_id"
    fi

else
    state="SUCCESS"
    log "SUCCESS job $job_id (${duration}ms)"
fi

# =========================
# DB UPDATE (SAFE)
# =========================
sqlite3 "$DB" <<EOF
UPDATE jobs
SET status='$state',
    output='$safe_output',
    duration=$duration,
    retry=$retry
WHERE id=$job_id;
EOF

done

log "SYSTEM DONE"

