#!/bin/bash

set -euo pipefail

IP=$1
USER=$2
PASS=$3

# Log the received arguments (for debugging)
echo "IP: $IP"
echo "USER: $USER"
echo "PASS: $PASS"


# Variables
RDP_USER="$USER"
RDP_PASSWORD="$PASS"
RDP_IP="$IP"
RDP_WINDOW_TITLE="FreeRDP: $RDP_IP"
BATCH_SCRIPT_PATH="https://github.com/Jasperdots/Vauto"
BATCH_SCRIPT_DIR="C:\\Users\\Administrator\\Desktop"

# Connect to RDP session
xfreerdp /u:$RDP_USER /p:$RDP_PASSWORD /v:$RDP_IP /cert:ignore &

# Wait for the RDP session to start
sleep 10

# Get the window ID of the RDP session
WINDOW_ID=$(wmctrl -l | grep "$RDP_WINDOW_TITLE" | awk '{print $1}')

# Check if the window ID is found
if [ -z "$WINDOW_ID" ]; then
  echo "RDP window not found."
  exit 1
fi

wait_for_cmd() {
  local retries=10
  local delay=1

  for ((i=0; i<retries; i++)); do
    # Check if the command prompt is ready (by checking window title)
    wmctrl -l | grep -q "$CMD_PROMPT_TITLE" && return 0
    sleep $delay
  done

  echo "Command Prompt did not become ready in time."
  return 1
}

# Open Notepad using Win+R and type 'notepad'
xdotool key --window $WINDOW_ID super+r
sleep 2
xdotool type --window $WINDOW_ID "cmd"
xdotool key --window $WINDOW_ID Return
sleep 5


# Save the batch script file
xdotool key --window $WINDOW_ID ctrl+s
sleep 2
xdotool type --window $WINDOW_ID "curl -o setup.bat $BATCH_SCRIPT_PATH"
xdotool key --window $WINDOW_ID Return
sleep 2


# Open Command Prompt and run the batch script
xdotool key --window $WINDOW_ID super+r
sleep 2
xdotool type --window $WINDOW_ID "cmd"
xdotool key --window $WINDOW_ID Return
sleep 4
xdotool type --window $WINDOW_ID "setup.bat"
xdotool key --window $WINDOW_ID Return


sleep 20

# Close the RDP window
xdotool windowclose "$WINDOW_ID"
