---
name: feishu-voice
description: 通过 Edge TTS 把文字转语音，发送到飞书。支持纯语音发送和文字+语音同时发送。触发词：飞书语音、发语音、feishu voice、语音发送
---

# Feishu Voice — 飞书语音发送工具

用 Edge TTS 把文字转语音，直接发到飞书。无需 API Key，完全免费。

## 依赖

- `edge-tts` — Microsoft Edge TTS
- `ffmpeg` — 音频格式转换（mp3 → opus）
- `curl` / `python3`

安装：
```bash
pip install edge-tts
# ffmpeg: apt install ffmpeg 或 brew install ffmpeg
```

## 配置

脚本从 `~/.openclaw/openclaw.json` 读取飞书凭证：

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
./feishu-voice-send.sh "你好，这是语音消息"
./feishu-voice-send.sh "你好" "ou_xxxxx" "zh-CN-YunxiNeural"
```

**可用中文语音：**
| 语音 | 说明 |
|------|------|
| zh-CN-XiaoxiaoNeural | 女声（晓晓） |
| zh-CN-YunxiNeural | 男声（云希） |
| zh-CN-XiaoyiNeural | 女声（晓伊） |
| zh-CN-YunyangNeural | 男声（云扬） |

### 2. feishu-send.sh（文字+语音同时发送）

```bash
./feishu-send.sh "详细文字内容..." "语音摘要，三句以内"
```

**规则：文字详细 + 语音简短**

## 技术原理

```
文字 → Edge TTS → MP3 → FFmpeg(opus) → 飞书文件上传 → audio消息
```

1. Edge TTS 把文字转成 MP3（免费、无需 API Key）
2. FFmpeg 把 MP3 转成飞书要求的 OPUS 格式
3. 上传到飞书获取 file_key
4. 发送 audio 消息

## 文件

- `feishu-voice-send.sh` — 核心脚本，纯语音发送
- `feishu-send.sh` — 文字+语音同时发送

## 常见问题

**Q: 语音没声音？**
A: 确保 ffmpeg 已安装且支持 libopus：`ffmpeg -formats | grep opus`

**Q: 发送失败？**
A: 检查 `~/.openclaw/openclaw.json` 配置是否正确

**Q: 可以发到群聊吗？**
A: 把 receive_id 改成群聊 ID（oc_xxxx）

## 项目地址

https://github.com/Mayiv-Ai/feishu-voice
