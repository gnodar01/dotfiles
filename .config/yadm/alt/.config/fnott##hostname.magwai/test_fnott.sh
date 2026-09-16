#!/usr/bin/env bash

kill -9 $(pgrep fnott)

echo "====== Starting notify-send Test Suite ======"

# Simple Notification
echo "Sending simple notification..."
notify-send "Test Title" "This is a basic desktop notification message."
sleep 1

# Urgency Levels
echo "Sending urgency tests..."
notify-send -u low "Low Urgency" "This is a low-priority background event."
sleep 1
notify-send -u normal "Normal Urgency" "Standard system alert level."
sleep 1
notify-send -u critical "Critical Urgency" "High priority! This often requires user acknowledgement."
sleep 1

# Notification with System Icon
echo "Sending icon test..."
# Uses standard system theme icons (like 'info', 'error', 'face-smile', 'battery')
notify-send -i "info" "Icon Test" "Successfully displayed using a system icon."
sleep 1

# Notification with Custom Icon
echo "Sending custom icon file path test..."
notify-send -i "/usr/share/pixmaps/archlinux-logo.png" "Custom Path Icon" "Successfully displayed using a custom icon path."
sleep 1

# Notification with App Name
echo "Sending notification with app name..."
notify-send -a "firefox" "Firefox sent notifcation" "Displayed using app name Firefox"
sleep 1

# Multi-line & HTML Formatting
echo "Sending formatted text test..."
notify-send "Formatted Text" "<b>Bold Text</b>, <i>Italics</i>, and a <u>Underline</u>.\nNew line support!"
sleep 1

# Expiring/Timing Out
echo "Sending timed notification..."
# Expire time in milliseconds (e.g., 2000ms = 2 seconds). 
# Note: Some modern desktop environments ignore this flag.
notify-send -t 5000 "Self-Destruct" "This text should vanish after 5 seconds."
sleep 1

# Synchronous Progress / Notification Replacement (Advanced)
echo "Sending manual progress replacement loop..."
# Initialize a notification and capture its unique ID
NOTIF_ID=$(notify-send -p "Task Status" "Initializing...")

for i in {25..100..25}; do
    sleep 1
    # Replace the existing notification window instantly rather than stacking a new box
    notify-send -r "$NOTIF_ID" --hint=INT:prog:$i "Task Status" "Processing data... $i% complete"
done

# Synchronous Progress Bar / Notification Replacement (Advanced)
echo "Sending progress bar replacement loop..."
# Initialize a notification and capture its unique ID
NOTIF_ID=$(notify-send -p "Task Status" "Initializing...")

for i in {0..100..2}; do
    sleep 0.1
    # Replace the existing notification window instantly rather than stacking a new box
    notify-send -r "$NOTIF_ID" --hint=INT:value:$i "Task Status"
done

echo "====== Test Suite Finished ======"

echo to dismiss notifications, rerun test or do: fnottctl dismiss all
