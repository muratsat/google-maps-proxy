#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

LOG_FILE="$SCRIPT_DIR/update-session-token.log"

exec > >(tee -a "$LOG_FILE") 2>&1
# exec >> "$LOG_FILE" 2>&1

OUTPUT="${1:-gmaps_secrets.conf}"

set -a
source $SCRIPT_DIR/.env
set +a

SESSION=$(curl -sX POST -d '{
  "mapType": "roadmap",
  "language": "en-US",
  "region": "US"
}' \
  -H 'Content-Type: application/json' \
  "https://tile.googleapis.com/v1/createSession?key=$GMAPS_API_KEY" | jq -r '.session')

cat > "$OUTPUT" <<EOF
set \$gmaps_api_key "$GMAPS_API_KEY";
set \$gmaps_session "$SESSION";
EOF

DATE=$(date)
echo "$DATE Wrote $OUTPUT"