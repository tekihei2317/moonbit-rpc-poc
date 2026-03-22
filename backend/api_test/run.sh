#!/usr/bin/env bash

set -euo pipefail

PORT="${PORT:-4001}"
HOST="${HOST:-http://127.0.0.1:${PORT}}"
SERVER_PID=""

stop_server() {
  if [ -n "$SERVER_PID" ]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
    SERVER_PID=""
  fi
}

run_test_file() {
  local file="$1"

  rm -f contacts.db

  moon run backend --target native -- --port "$PORT" &
  SERVER_PID=$!

  until curl -s -o /dev/null "$HOST/api/contacts"; do
    sleep 1
  done

  local exit_code=0
  hurl --test --jobs 1 --variable "host=$HOST" "$file" || exit_code=$?
  stop_server
  return "$exit_code"
}

trap stop_server EXIT

echo "Running Hurl tests against $HOST"

if [ $# -eq 0 ]; then
  for file in backend/api_test/*.hurl; do
    run_test_file "$file"
  done
else
  for file in "$@"; do
    run_test_file "$file"
  done
fi
