# Distributed Job Executor (V2)

A lightweight distributed job orchestration system built with Bash and SQLite.  
Designed to simulate core concepts of real-world schedulers like Kubernetes and Nomad using minimal tooling.

---

## 🚀 Features

- **SQLite Backend**  
  Centralized job queue, status tracking, and execution results.

- **Distributed Execution over SSH**  
  Jobs are dispatched to remote nodes via SSH.

- **Load Balancing**  
  Automatically selects the least loaded node using `/proc/loadavg`.

- **Retry Mechanism**  
  Failed jobs are automatically retried with a configurable limit.

- **Real-time Monitoring**  
  Live terminal dashboard and metrics reporting.

- **Event-driven Execution Model**  
  Jobs transition through states: `QUEUED → RUNNING → SUCCESS/FAIL`.

---

## 🛠 Tech Stack

- **Language:** Bash  
- **Database:** SQLite3  
- **Transport:** SSH  
- **Platform:** Linux (Arch / CachyOS optimized)

---

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
   
