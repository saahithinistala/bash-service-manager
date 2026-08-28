#!/bin/sh

cd "$(dirname "$0")"
python3 -m http.server 8081 > payment-service.log 2>&1 &
echo $! > payment-service.pid

echo "payment-service started successfully!"
