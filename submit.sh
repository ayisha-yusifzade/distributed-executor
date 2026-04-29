#!/bin/bash

DB="jobs.db"
cmd="$1"

if [ -z "$cmd" ]; then
  echo "Usage: ./submit.sh \"command\""
  exit 1
fi

sqlite3 "$DB" "INSERT INTO jobs(cmd,status,retry,created_at) VALUES('$cmd','QUEUED',0,datetime('now'));"

echo "[SUBMITTED] $cmd"
