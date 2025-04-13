#!/bin/bash

# URL of the file to be downloaded
URL="https://github.com/bambulab/BambuStudio/releases/download/v01.09.03.50/Bambu_Studio_linux_ubuntu-v01.09.03.50.AppImage"

# Destination path for the downloaded file
DESTINATION="./downloaded_file"

# Fetch the total file size using curl
total_size=$(curl -sI $URL | grep -i Content-Length | awk '{print $2}' | tr -d '\r')

# Download the file in the background with wget
wget $URL -O $DESTINATION &

# PID of the wget process
WGET_PID=$!

# Function to draw the progress bar
draw_progress_bar() {
  # $1 - Current progress (percentage)
  local progress=$1
  local filled=$((progress * 60 / 100)) # Assuming 60 characters wide progress bar
  local blanks=$((60 - filled))
  printf "\r["
  printf "%0.s#" $(seq 1 $filled)
  printf "%0.s-" $(seq 1 $blanks)
  printf "] %d%%" $progress
}

# Loop to update progress bar
while kill -0 $WGET_PID 2> /dev/null; do
  # Current size of the downloaded file
  current_size=$(stat -c %s "$DESTINATION" 2>/dev/null || echo 0)
  
  # Calculate current progress
  if [[ $total_size > 0 ]]; then
    current_progress=$((current_size * 100 / total_size))
  else
    current_progress=0
  fi

  # Draw the progress bar
  draw_progress_bar $current_progress

  # Sleep for 0.5 seconds before updating again
  sleep 0.5
done

# Final update to the progress bar to ensure it shows 100% at the end
draw_progress_bar 100
echo -e "\nDownload complete."
