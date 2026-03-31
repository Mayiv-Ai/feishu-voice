# Feishu Voice — 飞书语音发送工具

用 Edge TTS 把文字转语音，直接发到飞书。支持纯语音发送和文字+语音同时发送。无需 API Key，完全免费。

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

通过环境变量配置（更安全，适合 CI/CD 和生产环境）：

```bash
# 飞书应用凭证
export FEISHU_APP_ID="cli_xxxxxx"
export FEISHU_APP_SECRET="xxxxxxxx"

# 接收者 ID（二选一）
export FEISHU_RECEIVE_ID="ou_xxxxx"   # 用户 open_id
export FEISHU_CHAT_ID="oc_xxxxx"       # 群聊 ID
```

**获取方式：**
- 飞书应用凭证：开发者后台 → 应用凭证
- 用户 open_id：飞书开发者工具 → 成员 ID
- 群聊 ID：群设置 → 群信息 → 群 ID

## 使用方法

### 1. feishu-voice-send.sh（纯语音）

```bash
# 设置环境变量
export FEISHU_APP_ID="cli_xxxx"
export FEISHU_APP_SECRET="xxxxx"
export FEISHU_RECEIVE_ID="ou_xxxx"

# 基本用法
./feishu-voice-send.sh "你好，这是语音消息"

# 指定接收者和语音
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

## 安全说明

- 凭证通过环境变量传递，**不硬编码**在脚本中
- 推荐使用只读权限的飞书机器人，避免使用管理员凭证
- 生产环境建议配合 `.env` 文件和环境变量管理工具使用

## 常见问题

**Q: 语音没声音？**
A: 确保 ffmpeg 已安装且支持 libopus（`ffmpeg -formats | grep opus`）

**Q: 提示需要设置环境变量？**
A: 检查 FEISHU_APP_ID、FEISHU_APP_SECRET、FEISHU_RECEIVE_ID 是否已设置

**Q: 可以发到群聊吗？**
A: 把 `FEISHU_RECEIVE_ID` 改成群聊 ID（oc_xxxx），同时 msg_type 用 `interactive`

## 项目地址

https://github.com/Mayiv-Ai/feishu-voice
