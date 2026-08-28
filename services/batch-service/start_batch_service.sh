#!/bin/sh

cd "$(dirname "$0")"
python3 -m http.server 8084 > batch-service.log 2>&1 &
echo $! > batch-service.pid

echo "batch-service started successfully!"



