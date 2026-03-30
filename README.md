# Feishu Voice — 飞书语音发送工具

用 Edge TTS 把文字转语音，直接发到飞书。支持语音+文字同时发送。

## 功能

| 脚本 | 说明 |
|------|------|
| `feishu-voice-send.sh` | 纯语音发送 |
| `feishu-send.sh` | 文字+语音同时发送 |

## 依赖

- `edge-tts` — Microsoft Edge TTS（文字转语音）
- `ffmpeg` — 音频格式转换（mp3 → opus）
- `curl` / `python3` — HTTP 请求

安装依赖：
```bash
pip install edge-tts
# ffmpeg 通常已安装，或: apt install ffmpeg
```

## 配置

脚本从 `~/.openclaw/openclaw.json` 读取飞书 App ID 和 App Secret：

```json
{
  "channels": {
    "feishu": {
      "accounts": {
        "main": {
          "appId": "cli_xxxxxx",
          "appSecret": "xxxxxxxx"
        }
      }
    }
  }
}
```

## 使用方法

### 1. feishu-voice-send.sh（纯语音）

```bash
# 基本用法
./feishu-voice-send.sh "你好，这是语音消息"

# 指定接收者和语音
./feishu-voice-send.sh "你好" "ou_xxxxx" "zh-CN-YunxiNeural"

# 可用语音（中文）
zh-CN-XiaoxiaoNeural   # 女声（晓晓）
zh-CN-YunxiNeural      # 男声（云希）
zh-CN-XiaoyiNeural     # 女声（晓伊）
zh-CN-YunyangNeural    # 男声（云扬）
```

### 2. feishu-send.sh（文字+语音同时发送）

```bash
./feishu-send.sh "这是详细文字内容..." "这是语音摘要，三句话以内"
```

**规则：文字详细 + 语音简短**
- 文字：完整内容
- 语音：3句以内摘要

## 技术原理

```
文字 → Edge TTS → MP3 → FFmpeg(opus) → 飞书文件上传 → audio消息
```

1. Edge TTS 把文字转成 MP3（免费、无需 API Key）
2. FFmpeg 把 MP3 转成飞书要求的 OPUS 格式
3. 上传到飞书获取 file_key
4. 发送 audio 消息

## 常见问题

**Q: 语音没声音？**
A: 确保 ffmpeg 已安装且支持 libopus（`ffmpeg -formats | grep opus`）

**Q: 发送失败？**
A: 检查 `~/.openclaw/openclaw.json` 配置是否正确

**Q: 可以发到群聊吗？**
A: 把 receive_id 改成群聊 ID（oc_xxxx），msg_type 改成 `interactive` 用卡片消息

## License

MIT
