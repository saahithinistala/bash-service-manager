#!/bin/sh

cd "$(dirname "$0")"
python3 -m http.server 8082 > account-service.log 2>&1 &
echo $! > account-service.pid

echo "account-service started successfully!"



