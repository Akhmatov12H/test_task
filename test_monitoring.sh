#!/bin/bash

PROCESS_NAME="test"
MONITORING_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
STATE_FILE="/var/run/monitor_${PROCESS_NAME}.state"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

if pgrep -x "$PROCESS_NAME" > /dev/null; then

    LAST_STATE=$(cat "$STATE_FILE" 2>/dev/null)

    if [ "$LAST_STATE" = "STOPPED" ] || [ ! -f "$STATE_FILE" ]; then
        log_message "INFO: Process '$PROCESS_NAME' was restarted (or started for the first time)."
    fi

    echo "RUNNING" > "$STATE_FILE"

    curl -m 10 -s -o /dev/null "$MONITORING_URL"
    CURL_EXIT_CODE=$?

    if [ $CURL_EXIT_CODE -ne 0 ]; then
        log_message "ERROR: Monitoring server '$MONITORING_URL' is UNAVAILABLE (curl exit code: $CURL_EXIT_CODE)."
    fi

else
    echo "STOPPED" > "$STATE_FILE"
fi

exit 0
