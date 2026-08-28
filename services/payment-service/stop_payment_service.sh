#!/bin/sh

pid=$(lsof -ti :8081)

if [ -n "$pid" ]; then
    kill "$pid"
    echo "payment-service stopped successfully!"
else
    echo "payment-service is not running."
fi