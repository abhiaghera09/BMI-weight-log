#!/usr/bin/env bash
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_DIR
source "$PROJECT_DIR/lib/functions.sh"
ensure_project_files
while true; do
  echo
  echo "========== BMI & WEIGHT LOG =========="
  echo "1. Add weight entry"
  echo "2. Calculate BMI"
  echo "3. Show weight change"
  echo "4. Monthly average"
  echo "5. Generate health report"
  echo "6. View stored data"
  echo "7. Create backup"
  echo "8. View activity log"
  echo "0. Exit"
  read -r -p "Choose: " choice
  case "$choice" in
    1) add_entry ;;
    2) calculate_bmi ;;
    3) show_weight_change ;;
    4) monthly_average ;;
    5) generate_report ;;
    6) view_data ;;
    7) create_backup ;;
    8) view_activity_log ;;
    0) log_activity "Application closed"; echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid choice." ;;
  esac
done
