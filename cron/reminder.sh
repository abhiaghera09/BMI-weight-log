#!/usr/bin/env bash
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$PROJECT_DIR/logs"
echo "[$(date '+%F %T')] Weekly reminder: update your weight log." >> "$PROJECT_DIR/logs/activity.log"
echo "Reminder logged."
