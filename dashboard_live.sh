#!/bin/bash
DB="jobs.db"

while true; do
    clear
    echo "=========================================="
    echo "    LIVE ORCHESTRATOR DASHBOARD (V2)"
    echo "=========================================="
    # Son 10 işi səliqəli göstərir
    sqlite3 "$DB" -header -column "SELECT id, cmd, status, host, duration || 'ms' as time FROM jobs ORDER BY id DESC LIMIT 10;"
    
    echo -e "\n---- QUICK STATS ----"
    sqlite3 "$DB" -column "SELECT status, COUNT(*) FROM jobs GROUP BY status;"
    
    sleep 1
done
