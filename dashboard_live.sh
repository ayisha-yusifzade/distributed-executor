#!/bin/bash

DB="jobs.db"

while true; do
    clear

    echo "=============================="
    echo "  LIVE ORCHESTRATOR DASHBOARD"
    echo "=============================="

    sqlite3 "$DB" "SELECT id,cmd,status,host,duration FROM jobs ORDER BY id DESC;"

    echo ""
    echo "---- STATS ----"
    sqlite3 "$DB" "SELECT status, COUNT(*) FROM jobs GROUP BY status;"

    sleep 1
done
