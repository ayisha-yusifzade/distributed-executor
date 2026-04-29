# Distributed Job Executor (V2)

A lightweight, robust, and secure distributed task orchestration system built with Bash and SQLite. This tool allows for remote command execution over SSH with built-in retry logic and real-time monitoring.

##  Features

- **SQLite Backend:** Centralized job tracking, status management, and output logging.
- **Base64 Encoding:** Commands are encoded to ensure safe transmission of special characters (`&&`, `|`, quotes) over SSH.
- **Robust Retry Logic:** Automatic re-queueing of failed tasks with configurable maximum retry limits.
- **Real-time Monitoring:** Live dashboard and metrics reporting for system health and job success rates.
- **Security-First:** Minimal footprint, utilizing standard SSH protocols and secure data handling.

##  Technical Stack

- **Language:** Bash (Shell Scripting)
- **Database:** SQLite3
- **OS Support:** Linux (Optimized for Arch/CachyOS)
- **Transport:** SSH

##  Project Structure

- `init_db.sh`: Initializes the SQLite database and directory structure.
- `submit.sh`: Client tool to submit new jobs to the queue.
- `runner.sh`: The core orchestrator that dispatches jobs to nodes.
- `worker.sh`: Remote execution engine (payload).
- `metrics.sh`: Generates success/fail statistics.
- `dashboard_live.sh`: A live, auto-refreshing terminal dashboard.

##  Quick Start

1. **Initialize the system:**
   ```bash
   ./init_db.sh
   
2. **Submit a task:**
    ```bash
   ./submit.sh "uptime && df -h"
    
3. **Start the orchestrator::**
    ```bash
    ./runner.sh
    
5. **Monitor progress::**
    ```bash
    ./dashboard_live.sh
   
