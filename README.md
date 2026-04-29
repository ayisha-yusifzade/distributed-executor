# Distributed Job Executor

A lightweight, robust distributed task orchestration system built with Bash and SQLite. This project simulates core concepts of production-grade schedulers like Kubernetes or Nomad using minimal system tools.

##  Key Features

- **SQLite Persistence** Centralized job queue, state tracking, and execution history.

- **Robust Command Encoding** Uses **Base64 encoding** to safely transmit commands containing special characters (`&&`, `|`, quotes) over SSH.

- **Event-Driven State Machine** Jobs transition through: `QUEUED → RUNNING → SUCCESS / FAIL`.

- **Automatic Retry Mechanism** Failed jobs are re-queued until a configurable retry limit is reached.

- **Safe Output Handling** Escapes special characters (SQL escaping) before storing command output in SQLite.

- **Observability** Live terminal dashboard and metrics reporting for real-time system visibility.

##  How It Works (Workflow)

The system follows a structured execution pipeline to ensure reliability and traceability:

1. **Ingestion:** Jobs are inserted into SQLite with `QUEUED` state via `submit.sh`.
2. **Selection:** The `runner.sh` (orchestrator) selects jobs using FIFO scheduling.
3. **Encapsulation:** Commands are Base64-encoded to prevent shell parsing issues during transmission.
4. **Dispatch:** Encoded payload is sent to a worker node over SSH.
5. **Execution:** The `worker.sh` decodes and executes the command, capturing output.
6. **Finalization:** Execution results and duration are stored in the database.

##  Technical Stack

- **Language:** Bash (Shell Scripting)
- **Database:** SQLite3
- **Transport:** SSH (Key-based authentication)
- **Environment:** Linux (Arch / CachyOS optimized)

##  Project Structure

| File | Role | Description |
| :--- | :--- | :--- |
| `init_db.sh` | **Setup** | Bootstraps the SQLite database and folder structure. |
| `submit.sh` | **Producer** | Adds new tasks to the queue. |
| `runner.sh` | **Orchestrator**| The main engine: handles encoding, dispatching, and retries. |
| `worker.sh` | **Consumer** | Executes the decoded payload on the remote node. |
| `metrics.sh` | **Analytics** | Calculates system performance statistics. |
| `dashboard_live.sh` | **UI** | Live monitoring dashboard. |

##  Quick Start

1. **Initialize the system:**
   ```bash
   ./init_db.sh
   
2. **Submit a task:**
    ```bash
   ./submit.sh "uptime && df -h"
    
3. **Start the orchestrator:**
    ```bash
    ./runner.sh

4. **Monitor progress:**
    ```bash
    ./dashboard_live.sh 

---

##  Concepts Demonstrated

- **Distributed Scheduling** Coordinating task execution across multiple compute nodes to balance workload.

- **Remote Command Execution (RCE)** Safely executing commands on remote systems using secure SSH tunnels.

- **Fault Tolerance** Built-in retry mechanism to handle transient network issues or execution failures.

- **Observability** Integrated CLI-based dashboard for real-time system health and task monitoring.

---

##  Important Notes

- **SSH Setup Required** Passwordless SSH (SSH keys) must be configured between the orchestrator and worker nodes for seamless execution.

- **Educational Purpose** This project is specifically designed for learning distributed systems architecture and DevOps fundamentals.

- **Not Production Ready** Lacks advanced sandboxing, containerization (Docker), and isolation required for secure multi-tenant execution.
