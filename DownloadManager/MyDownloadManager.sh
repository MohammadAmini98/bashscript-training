#!/bin/bash

# Ask user for URL to download
read -p "Enter the URL to download: " URL

# Ask user for file name to save as
read -p "Enter the file name to save as: " FILENAME

# Ask user for start time
read -p "Enter the start time in HH:MM format: " START_TIME

# Ask user for end time
read -p "Enter the end time in HH:MM format: " END_TIME

# Convert start time and end time to seconds since midnight
START_SECONDS=$(date -d "$START_TIME" +"%s" 2>/dev/null)
END_SECONDS=$(date -d "$END_TIME" +"%s" 2>/dev/null)

# Check if start time and end time are valid
if [ -z "$START_SECONDS" ] || [ -z "$END_SECONDS" ]; then
  echo "Invalid start time or end time."
  exit 1
fi

# Calculate duration of download in seconds
DURATION=$((END_SECONDS - START_SECONDS))

# Check if download duration is negative
if [ $DURATION -lt 0 ]; then
  echo "End time is before start time."
  exit 1
fi

# Wait until start time
CURRENT_SECONDS=$(date +"%s")

# Calculate seconds until start time
SECONDS_TO_START=$((START_SECONDS - CURRENT_SECONDS))

# Check if start time is in the future
if [ $SECONDS_TO_START -gt 0 ]; then
  echo "Waiting for download to start..."
  sleep $SECONDS_TO_START
fi

# Record start time
START_TIME=$(date +"%T")

# Download file using wget in the background
wget $URL -O $FILENAME &PID=$!

# Wait until end time or download is complete
while true; do
  CURRENT_SECONDS=$(date +"%s")
  TIME_LEFT=$((END_SECONDS - CURRENT_SECONDS))
  if [ $TIME_LEFT -le 0 ]; then
    echo "End time has been reached. Stopping download..."
    kill $PID
    break
  fi
  sleep 1
done

# Record end time
END_TIME=$(date +"%T")

# Calculate actual duration of download in seconds
ACTUAL_DURATION=$((END_SECONDS - START_SECONDS))

# Display download duration
echo "Download completed in $(date -d@$ACTUAL_DURATION -u +%H:%M:%S)."
PID=$!
kill $PID
