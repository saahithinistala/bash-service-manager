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

## Files
* service_manager.sh - Main Bash script
* services_config.cfg - Contains service name, start script, stop script, port and service directory details
* services - Contains test service start and stop scripts

## Services Used
1. Payment Service
2. Account Service
3. Notification Service
4. Batch Service

## Run
Interactive Mode:

./service_manager.sh

This displays a menu where the required service operation can be selected.

### Command-Line Mode
Examples:

* ./service_manager.sh start payment-service
* ./service_manager.sh stop payment-service
* ./service_manager.sh restart payment-service
* ./service_manager.sh health all
* ./service_manager.sh auto-recover all

The script supports both individual service names and "all".

## Auto Recovery
The auto-recovery option performs a health check on the selected service.
If a service is not running, the script tries to stop any partial/stale service process, starts the service again, and performs another health check.

At the end, it displays a summary such as:
===== AUTO RECOVERY SUMMARY =====
payment-service        : RUNNING
account-service        : RUNNING
notification-service   : RECOVERED
batch-service          : RUNNING

## Purpose
I created this project to brush up Bash scripting concepts such as functions, loops, case statements, command-line arguments, configuration file handling, service health checks and basic automatic recovery.
