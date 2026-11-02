# BMI & Weight Log (Linux Bash)

Menu-driven Bash project to record weight/height, calculate BMI, compare first and latest weight, calculate monthly averages, generate reports, create tar backups, and log activity.

## Run
```bash
chmod +x main.sh
./main.sh
```

## Menu
1. Add weight entry
2. Calculate BMI
3. Show weight change
4. Monthly average
5. Generate health report
6. View stored data
7. Create backup
8. View activity log
0. Exit

## Data
`data/health.csv` format: `date,weight_kg,height_cm`. The included 15 rows are sample data; replace them with your own test data. Do not commit private health information.

## BMI
BMI = weight in kg / (height in metres × height in metres). Categories shown are common adult screening ranges, not a medical diagnosis.

## Weekly cron reminder
On a Linux machine with cron enabled, use:
`0 8 * * 0 /absolute/path/to/BMI-Weight-Log/cron/reminder.sh`
Coddy may not support persistent cron services; if unavailable, run `bash cron/reminder.sh` manually.
