#!/usr/bin/env bash
# feishu-send.sh — Send text + voice simultaneously to Feishu
# Usage: feishu-send.sh "<text>" "<voice_summary>"
#
# Both text and voice are MANDATORY. No exceptions.
# Text = detailed content, Voice = brief summary (3 sentences)

TEXT="$1"
VOICE="$2"

if [ -z "$TEXT" ] || [ -z "$VOICE" ]; then
    echo "Usage: feishu-send.sh <text> <voice_summary>"
    exit 1
fi

# Load credentials
CONFIG="/home/boge/.openclaw/openclaw.json"
APP_ID=$(python3 -c "import json; print(json.load(open('$CONFIG'))['channels']['feishu']['accounts']['main']['appId'])")
APP_SECRET=$(python3 -c "import json; print(json.load(open('$CONFIG'))['channels']['feishu']['accounts']['main']['appSecret'])")

# Get token
TOKEN=$(curl -sf -X POST 'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal' \
    -H 'Content-Type: application/json' \
    -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['tenant_access_token'])")

# Send text
python3 << PYEOF
import json, urllib.request, sys

text = """$TEXT"""
text = text.replace('\\n', '\n').replace('\\r', '\r')

payload = {
    "receive_id": "ou_XXXXXXXXXXXXXXXXXXXXXXXXXX",
    "msg_type": "text",
    "content": json.dumps({"text": text})
}

body = json.dumps(payload).encode()
req = urllib.request.Request(
    "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id",
    data=body,
    headers={"Authorization": f"Bearer $TOKEN", "Content-Type": "application/json"}
)
result = json.loads(urllib.request.urlopen(req).read())
code = result.get("code", -1)
mid = result.get("data", {}).get("message_id", "")
print(f"TEXT_OK mid={mid}" if code == 0 else f"TEXT_ERR code={code} msg={result.get('msg')}")
PYEOF

# Send voice (MANDATORY)
bash "$(dirname "$0")/feishu-voice-send.sh" "$VOICE"
