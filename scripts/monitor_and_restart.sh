#!/usr/bin/env bash
# monitor OpenClaw logs for a specific error pattern and trigger an LM Studio restart via API

LOG_FILE="$(realpath /var/log/openclaw.log)"
PATTERN='error \[tools\] exec failed: /bin/bash: -c: line 1: unexpected EOF while looking for matching `"|TimeoutOverflowWarning: 2592010000 does not fit into a 32-bit signed integer. Timeout duration was set to 1.'
RETRY_LIMIT=3

# Function that deletes the current model and re‑adds it after a short pause
restart_lmstudio() {
    echo "Attempting to reset LM Studio model..."
    # Delete the model (replace query or path if needed)
    DEL=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE http://172.18.80.1:1235/api/v1/models?model=openai/gpt-oss-20b)
    echo "Delete response code: $DEL"
    sleep 3
    # Re‑add the model (empty body, adjust if LM Studio requires JSON)
    ADD=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://172.18.80.1:1235/api/v1/models)
    echo "Add response code: $ADD"
}

# Main loop: tail the log and look for the pattern
while true; do
    # Wait for a new line in the log
    if read -r LINE <&3; then
        echo "Log: $LINE" >&2
        if [[ "$LINE" == *$PATTERN* ]]; then
            echo "Error detected – initiating LM Studio restart sequence" >&2
            retry=0
            while (( retry<RETRY_LIMIT )); do
                restart_lmstudio && break
                retry=$((retry+1))
                sleep 5
            done
        fi
    else
        # Log file rotated or closed; reopen
        exec 3< "$LOG_FILE"
    fi
done &

# Open the log for reading from the beginning
exec 3< "$LOG_FILE"
wait
