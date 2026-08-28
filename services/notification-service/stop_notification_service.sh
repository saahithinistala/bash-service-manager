#!/bin/sh

pid=$(lsof -ti :8083)

if [ -n "$pid" ]; then
    kill "$pid"
    echo "notification-service stopped successfully!"
else
    echo "notification-service is not running."
fi