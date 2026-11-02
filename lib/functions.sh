#!/usr/bin/env bash
DATA_FILE="$PROJECT_DIR/data/health.csv"
REPORT_DIR="$PROJECT_DIR/reports"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_FILE="$PROJECT_DIR/logs/activity.log"

ensure_project_files() {
 mkdir -p "$PROJECT_DIR"/{lib,data,reports,backups,logs}
 [[ -f "$DATA_FILE" ]] || echo "date,weight_kg,height_cm" > "$DATA_FILE"
 touch "$LOG_FILE"
}
log_activity() { echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"; }
valid_num() { [[ "$1" =~ ^[0-9]+([.][0-9]+)?$ ]] && awk -v n="$1" 'BEGIN{exit !(n>0)}'; }

add_entry() {
 read -r -p "Weight (kg): " w
 read -r -p "Height (cm): " h
 read -r -p "Date YYYY-MM-DD (blank=today): " d
 d="${d:-$(date +%F)}"
 if ! valid_num "$w" || ! valid_num "$h" || ! date -d "$d" >/dev/null 2>&1; then echo "Invalid input."; return; fi
 echo "$d,$w,$h" >> "$DATA_FILE"
 log_activity "Added entry $d, ${w}kg, ${h}cm"
 echo "Entry saved."
}
calculate_bmi() {
 read -r -p "Weight (kg): " w
 read -r -p "Height (cm): " h
 if ! valid_num "$w" || ! valid_num "$h"; then echo "Enter positive numbers."; return; fi
 bmi=$(awk -v w="$w" -v h="$h" 'BEGIN{printf "%.2f",w/((h/100)^2)}')
 category=$(awk -v b="$bmi" 'BEGIN{if(b<18.5)print "Underweight";else if(b<25)print "Normal weight";else if(b<30)print "Overweight";else print "Obesity"}')
 echo "BMI: $bmi | Category: $category"
 log_activity "BMI calculated: $bmi ($category)"
}
show_weight_change() {
 vals=$(awk -F, 'NR>1 && $2 ~ /^[0-9]+([.][0-9]+)?$/ {if(!n)first=$2;last=$2;n++} END{if(n>=2)printf "%s %s",first,last;else print "FEW"}' "$DATA_FILE")
 if [[ "$vals" == FEW ]]; then echo "Need at least two entries."; return; fi
 read -r first last <<< "$vals"
 diff=$(awk -v a="$first" -v b="$last" 'BEGIN{printf "%.2f",b-a}')
 echo "First: $first kg | Latest: $last kg | Change: $diff kg"
 log_activity "Viewed weight change: $diff kg"
}
monthly_average() {
 read -r -p "Month (1-12): " m; read -r -p "Year (YYYY): " y
 if [[ ! "$m" =~ ^([1-9]|1[0-2])$ || ! "$y" =~ ^[0-9]{4}$ ]]; then echo "Invalid month/year."; return; fi
 mm=$(printf "%02d" "$m")
 avg=$(awk -F, -v m="$mm" -v y="$y" 'NR>1 && substr($1,1,4)==y && substr($1,6,2)==m && $2 ~ /^[0-9]+([.][0-9]+)?$/ {s+=$2;n++} END{if(n)printf "%.2f",s/n;else print "NO_DATA"}' "$DATA_FILE")
 [[ "$avg" == NO_DATA ]] && echo "No entries for $y-$mm." || echo "Average weight for $y-$mm: $avg kg"
 log_activity "Monthly average checked for $y-$mm"
}
generate_report() {
 f="$REPORT_DIR/report_$(date +%Y%m%d_%H%M%S).txt"
 count=$(awk 'END{print NR-1}' "$DATA_FILE")
 first=$(awk -F, 'NR==2{print $2}' "$DATA_FILE")
 last=$(awk -F, 'END{if(NR>1) {split($0,a,",");print a[2]}}' "$DATA_FILE")
 avg=$(awk -F, 'NR>1 && $2 ~ /^[0-9]+([.][0-9]+)?$/ {s+=$2;n++} END{if(n)printf "%.2f",s/n;else print "N/A"}' "$DATA_FILE")
 { echo "BMI & WEIGHT LOG REPORT"; echo "Generated: $(date)"; echo "Entries: $count"; echo "First weight: ${first:-N/A} kg"; echo "Latest weight: ${last:-N/A} kg"; echo "Average weight: $avg kg"; echo; cat "$DATA_FILE"; } > "$f"
 log_activity "Generated report $(basename "$f")"
 echo "Report saved: $f"; cat "$f"
}
view_data() { echo "Stored CSV data:"; column -s, -t "$DATA_FILE" 2>/dev/null || cat "$DATA_FILE"; log_activity "Viewed data"; }
create_backup() {
 f="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
 tar -czf "$f" -C "$PROJECT_DIR" main.sh lib data reports logs README.md
 log_activity "Created backup $(basename "$f")"; echo "Backup created: $f"
}
view_activity_log() { tail -n 20 "$LOG_FILE"; }
