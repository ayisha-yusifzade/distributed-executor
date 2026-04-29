#!/bin/bash
DB="jobs.db"

echo "=============================="
echo "    SYSTEM METRICS REPORT"
echo "=============================="

TOTAL=$(sqlite3 "$DB" "SELECT COUNT(*) FROM jobs;")
SUCCESS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM jobs WHERE status='SUCCESS';")
FAIL=$(sqlite3 "$DB" "SELECT COUNT(*) FROM jobs WHERE status='FAIL';")

echo "📊 JOB COUNTS"
echo "------------------------------"
echo "Total    : $TOTAL"
echo "Success  : $SUCCESS"
echo "Fail     : $FAIL"

echo ""
echo "📈 SUCCESS RATE"
if [ "$TOTAL" -gt 0 ]; then
    RATE=$(awk "BEGIN {printf \"%.2f\", ($SUCCESS / $TOTAL) * 100}")
    echo "$RATE%"
else
    echo "0%"
fi

echo ""
echo "⚡ STATUS BREAKDOWN"
sqlite3 "$DB" -header -column "SELECT status, COUNT(*) as count FROM jobs GROUP BY status;"
echo "=============================="
