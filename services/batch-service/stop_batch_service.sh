#!/bin/sh

pid=$(lsof -ti :8084)

if [ -n "$pid" ]; then
    kill "$pid"
    echo "batch-service stopped successfully!"
else
    echo "batch-service is not running."
fi