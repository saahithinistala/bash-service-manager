# Bash Service Manager
This is a small Bash scripting project I created as part of my SRE/DevOps practice.
The script can manage multiple services using a menu-based interface.

## Features
* Start a service
* Stop a service
* Restart a service
* Perform health check
* Manage individual services or all services
* Read service details from a configuration file
* Check service status using port information

## Files
* service_manager.sh - Main Bash script
* services_config.cfg - Contains service name, start script, stop script, port and service directory details

## Services Used
* Payment Service
* Account Service
* Notification Service
* Batch Service

## Run
./service_manager.sh

The script displays a menu where the required service operation can be selected.

## Purpose
I created this project to brush up Bash scripting concepts such as functions, loops, case statements, configuration file handling and basic service health checks.
