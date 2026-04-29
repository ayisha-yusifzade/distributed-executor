#!/bin/bash

DB="jobs.db"

while true; do
clear

echo "=============================="
echo "   🚀 LIVE ORCHESTRATOR UI"
echo "=============================="

sqlite3 "$DB" "SELECT id,cmd,status,host,duration FROM jobs ORDER BY id DESC LIMIT 15;"

echo ""
echo "------ STATS ------"
sqlite3 "$DB" "SELECT status, COUNT(*) FROM jobs GROUP BY status;"

echo ""
echo "🧠 NODE STATUS"
for n in node1 node2 node3; do
    echo -n "$n → "
    ssh $n uptime 2>/dev/null | awk -F'load average:' '{print $2}'
done

sleep 1
done
