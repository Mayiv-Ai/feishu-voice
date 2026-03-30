#!/usr/bin/env bash
# feishu-voice-send.sh — Edge TTS → OPUS → Feishu audio message
# Usage: feishu-voice-send.sh <text> [receive_id] [voice]
#
# Defaults:
#   receive_id: ou_XXXXXXXXXXXXXXXXXXXXXXXXXX (博哥)
#   voice: zh-CN-XiaoxiaoNeural

TEXT="${1:?Usage: feishu-voice-send.sh <text> [receive_id] [voice]}"
RECEIVE_ID="${2:-ou_XXXXXXXXXXXXXXXXXXXXXXXXXX}"
VOICE="${3:-zh-CN-XiaoxiaoNeural}"

# Load credentials from openclaw config
CONFIG="/home/boge/.openclaw/openclaw.json"
APP_ID=$(python3 -c "import json,sys; d=json.load(open('$CONFIG')); print(d['channels']['feishu']['accounts']['main']['appId'])")
APP_SECRET=$(python3 -c "import json,sys; d=json.load(open('$CONFIG')); print(d['channels']['feishu']['accounts']['main']['appSecret'])")

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

MP3="$TMPDIR/voice.mp3"
OPUS="$TMPDIR/voice.opus"

# Step 1: TTS via edge-tts
edge-tts -t "$TEXT" -v "$VOICE" --write-media "$MP3" 2>/dev/null

# Step 2: Convert to opus
ffmpeg -y -i "$MP3" -c:a libopus -b:a 32k "$OPUS" >/dev/null 2>&1

# Step 3: Get duration
DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OPUS" | cut -d. -f1)
[ -z "$DURATION" ] && DURATION=1

# Step 4: Get tenant_access_token
TOKEN=$(curl -sf -X POST 'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal' \
  -H 'Content-Type: application/json' \
  -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['tenant_access_token'])")

# Step 5: Upload opus
FILE_KEY=$(curl -sf -X POST 'https://open.feishu.cn/open-apis/im/v1/files' \
  -H "Authorization: Bearer $TOKEN" \
  -F 'file_type=opus' \
  -F 'file_name=voice.opus' \
  -F "file=@$OPUS" \
  -F "duration=$DURATION" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['file_key'] if d.get('code')==0 else f\"ERROR: {d.get('msg')}\")")

# Step 6: Send audio message
RESULT=$(curl -sf -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d "{\"receive_id\":\"$RECEIVE_ID\",\"msg_type\":\"audio\",\"content\":\"{\\\"file_key\\\":\\\"$FILE_KEY\\\"}\"}" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"OK|{d['data']['message_id']}\" if d.get('code')==0 else f\"ERROR|{d.get('msg')}\")")

echo "$RESULT"
