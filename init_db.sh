#!/bin/bash
# Initialize SQLite database schema
sqlite3 jobs.db <<EOF
CREATE TABLE IF NOT EXISTS jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cmd TEXT NOT NULL,
    status TEXT DEFAULT 'QUEUED',
    host TEXT,
    output TEXT,
    retry INTEGER DEFAULT 0,
    duration INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
EOF

# Create necessary directories
mkdir -p logs
touch logs/system.log

echo "[OK] Database and directories initialized."
