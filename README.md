# Bash Service Manager
This is a small Bash scripting project I created as part of my SRE/DevOps practice.
The script can manage multiple services using both an interactive menu and command-line arguments.

## Features
* Start a service
* Stop a service
* Restart a service
* Perform health checks
* Manage individual services or all services
* Read service details from a configuration file
* Check service status using port information
* Run service actions through command-line arguments
* Automatically recover services that are not running
* Display an auto-recovery summary
* Write daily service manager logs
* Use INFO, WARN and ERROR log levels
* Send an email alert when automatic recovery fails
* Perform basic log housekeeping

## Files
* service_manager.sh - Main Bash script
* services_config.cfg - Contains service name, start script, stop script, port and service directory details
* services/ - Contains test service start and stop scripts
* logs/ - Runtime service manager and alert logs
* examples/sample_service_manager.txt - Sample service manager log output
* .smtp_config - Local SMTP configuration used for email alerts (excluded from Git)

## Services Used
* Payment Service
* Account Service
* Notification Service
* Batch Service

## Run
Interactive Mode

./service_manager.sh

This displays a menu where the required service operation can be selected.

### Command-Line Mode
Examples:

* ./service_manager.sh start payment-service
* ./service_manager.sh stop payment-service
* ./service_manager.sh restart payment-service
* ./service_manager.sh health all
* ./service_manager.sh auto-recover all

The script supports both individual service names and `all`.

## Auto Recovery
The auto-recovery option performs a health check on the selected service.
If a service is not running, the script tries to stop any partial or stale service process, starts the service again, and performs another health check.
At the end, it displays a summary such as:

```text
===== AUTO RECOVERY SUMMARY =====
payment-service        : RUNNING
account-service        : RUNNING
notification-service   : RECOVERED
batch-service          : RUNNING
```

If recovery fails, the service is reported as `FAILED` and an email alert is sent.

## Logging
The script writes daily logs to:

```text
logs/service_manager_YYYY-MM-DD.log
```

Log levels used:
```text
INFO
WARN
ERROR
```

Example:
```text
2026-08-30 16:14:38 WARN Auto-recovery triggered for payment-service
2026-08-30 16:14:41 INFO Starting payment-service
2026-08-30 16:14:44 INFO payment-service is running
2026-08-30 16:14:44 INFO payment-service recovered successfully
```

A sample log is available in:
```text
examples/sample_service_manager.txt
```

## Email Alerts
If automatic recovery fails, the script sends an email alert using SMTP.
SMTP credentials are stored locally in:

```text
.smtp_config
```

This file is excluded from Git using `.gitignore`.

## Housekeeping
The script removes temporary status files after execution and deletes alert logs older than 30 days.

## Purpose
I created this project to brush up Bash scripting concepts such as functions, loops, case statements, command-line arguments, configuration file handling, service health checks, logging, automatic recovery and basic alerting.
