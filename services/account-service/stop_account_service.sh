#!/bin/sh

pid=$(lsof -ti :8082)

if [ -n "$pid" ]; then
    kill "$pid"
    echo "account-service stopped successfully!"
else
    echo "account-service is not running."
fi