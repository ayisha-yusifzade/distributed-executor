#!/bin/bash

QUEUE_FILE="jobs/queue.json"

echo "=============================="
echo "   SYSTEM METRICS REPORT"
echo "=============================="

TOTAL=$(jq '. | length' "$QUEUE_FILE")

SUCCESS=$(jq '[.[] | select(.status=="SUCCESS")] | length' "$QUEUE_FILE")
FAIL=$(jq '[.[] | select(.status=="FAIL")] | length' "$QUEUE_FILE")
RUNNING=$(jq '[.[] | select(.status=="RUNNING")] | length' "$QUEUE_FILE")
QUEUED=$(jq '[.[] | select(.status=="QUEUED")] | length' "$QUEUE_FILE")

echo ""
echo "📊 JOB COUNTS"
echo "------------------------------"
echo "Total   : $TOTAL"
echo "Success : $SUCCESS"
echo "Fail    : $FAIL"
echo "Running : $RUNNING"
echo "Queued  : $QUEUED"

echo ""
echo "📈 SUCCESS RATE"
echo "------------------------------"

if [ $TOTAL -gt 0 ]; then
    RATE=$(( SUCCESS * 100 / TOTAL ))
    echo "$RATE%"
else
    echo "0%"
fi

echo ""
echo "⚡ STATUS BREAKDOWN"
echo "------------------------------"
jq -r '.[] | .status' "$QUEUE_FILE" | sort | uniq -c

echo ""
echo "=============================="
