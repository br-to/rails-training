#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

echo "Starting Rails server..."
# Start the Rails server
exec "$@"
