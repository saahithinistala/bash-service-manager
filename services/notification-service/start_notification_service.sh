#!/bin/sh

cd "$(dirname "$0")"
python3 -m http.server 8083 > notification-service.log 2>&1 &
echo $! > notification-service.pid

echo "notification-service started successfully!"



