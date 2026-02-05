#!/usr/bin/env bash
# Small background monitor for LM Studio
# Usage: ./monitor_lmstudio.sh &
# It watches the OpenClaw log for a specific error string and restarts LM Studio.

LOG_FILE="/var/log/openclaw.log"
ERROR_PATTERN="LM Studio failed to start"  # Adjust to actual error message
RESTART_CMD="openclaw gateway restart"   # Or use systemctl if installed

# Ensure log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Log file $LOG_FILE not found. Exiting." >&2
    exit 1
fi

# Tail the log and react to error
while true; do
    # Read new lines from log
    tail -n0 -F "$LOG_FILE" | while read -r line; do
        if [[ "$line" == *"$ERROR_PATTERN"* ]]; then
            echo "[$(date +%Y-%m-%dT%H:%M:%S)] Detected error: $line"
            echo "Restarting LM Studio..."
            # Restart command
            eval "$RESTART_CMD"
        fi
    done
done
