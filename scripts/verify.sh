#!/bin/bash
set -euo pipefail

PROXY="${PROXY:-http://127.0.0.1:3128}"
FAIL=0

check() {
  local name="$1"
  local code="$2"
  local expect="$3"
  if [[ "$code" == "$expect" ]]; then
    echo "OK  $name -> $code"
  else
    echo "FAIL $name -> $code (expected $expect)"
    FAIL=1
  fi
}

http_code() {
  curl -x "$PROXY" -sI --max-time 15 "$1" 2>/dev/null | grep -E '^HTTP/[12]' | tail -1 | awk '{print $2}'
}

echo "=== fusion-proxy verify (PROXY=$PROXY) ==="

check "api.aps.autodesk.com/health" "$(http_code https://api.aps.autodesk.com/health)" "200"
check "api.aps.usa.autodesk.com/health" "$(http_code https://api.aps.usa.autodesk.com/health)" "200"
check "signin.autodesk.com" "$(http_code https://signin.autodesk.com)" "200"
check "appstreaming health" "$(http_code https://www.appstreaming.autodesk.com/health)" "200"

PUBNUB=$(python3 - <<'PY'
import socket
req = 'GET https://pubsub.pubnub.com/time/0 HTTP/1.1\r\nHost: pubsub.pubnub.com\r\nConnection: close\r\n\r\n'
s = socket.create_connection(('127.0.0.1', 3128), 15)
s.sendall(req.encode())
status = s.recv(512).split(b'\r\n')[0].decode().split()[1]
s.close()
print(status)
PY
)
check "pubnub GET https://" "$PUBNUB" "200"

if ss -tlnp | grep ':3128' | grep -q mitmdump; then
  echo "OK  listener -> mitmdump :3128"
elif ss -tlnp | grep -q ':3128'; then
  echo "FAIL listener -> not mitmdump"
  FAIL=1
else
  echo "FAIL listener -> :3128 not listening"
  FAIL=1
fi

systemctl is-active --quiet fusion-proxy && echo "OK  fusion-proxy.service active" || { echo "FAIL fusion-proxy.service"; FAIL=1; }

exit "$FAIL"
