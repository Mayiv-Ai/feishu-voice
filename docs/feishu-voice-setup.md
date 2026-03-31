# 飞书语音对话功能部署指南

本文档介绍如何在 OpenClaw 中配置飞书语音对话功能，包括：
- 飞书机器人配置
- Whisper 语音识别安装（国内镜像）
- TTS 语音合成

---

## 1. 飞书机器人配置

### 1.1 创建飞书应用

1. 访问 [飞书开放平台](https://open.feishu.cn/app)
2. 创建企业应用 → 填写名称和描述
3. 获取 **App ID** 和 **App Secret**

### 1.2 配置权限

在飞书应用的「权限管理」中，批量导入以下权限：

```json
{
  "scopes": {
    "tenant": [
      "im:message",
      "im:message:send_as_bot",
      "im:message:readonly",
      "im:chat.members:bot_access"
    ],
    "user": []
  }
}
```

### 1.3 启用 Bot 能力

在「应用能力」→「Bot」中启用 Bot 能力。

### 1.4 配置事件订阅

1. 选择「使用长连接接收事件」（WebSocket）
2. 添加事件：`im.message.receive_v1`
3. 发布应用

### 1.5 在 OpenClaw 中配置

```bash
openclaw channels add
```

选择 **Feishu**，输入 App ID 和 App Secret。

或者直接编辑配置文件 `~/.openclaw/openclaw.json`：

```json
{
  "channels": {
    "feishu": {
      "enabled": true,
      "dmPolicy": "pairing",
      "accounts": {
        "main": {
          "appId": "cli_xxx",
          "appSecret": "xxx",
          "botName": "OpenClaw Assistant"
        }
      }
    }
  }
}
```

### 1.6 配对连接

```bash
openclaw pairing approve feishu <CODE>
```

---

## 2. Whisper 语音识别安装

### 2.1 安装 faster-whisper

由于服务器网络受限，建议使用国内镜像源：

```bash
# 创建虚拟环境
python3 -m venv .venv

# 安装 faster-whisper（使用国内镜像）
HF_ENDPOINT=https://hf-mirror.com .venv/bin/pip install faster-whisper
```

### 2.2 下载模型

首次使用时会自动下载模型。如果网络不通，可手动下载：

```bash
# 使用国内镜像下载 tiny 模型
HF_ENDPOINT=https://hf-mirror.com huggingface-cli download openai/whisper-tiny
```

### 2.3 测试识别

```bash
.venv/bin/python -c "
from faster_whisper import WhisperModel
model = WhisperModel('tiny', device='cpu', compute_type='int8')
segments, info = model.transcribe('audio.wav')
for segment in segments:
    print(segment.text)
"
```

---

## 3. 语音识别自动化（可选）

### 3.1 方案一：飞书转文字

在飞书中收到语音消息时：
1. 长按语音 → 点「转文字」
2. 将文字复制发送

### 3.方案二：本地 Whisper 识别

1. 飞书收到语音 → 下载 .ogg 文件
2. ffmpeg 转换为 16kHz 单声道 WAV
3. 用 Whisper 本地识别
4. 识别结果发送给 OpenClaw

```bash
# 转换格式
ffmpeg -i input.ogg -ar 16000 -ac 1 -acodec pcm_s16le output.wav

# 识别
whisper output.wav --model tiny
```

---

## 4. TTS 语音合成

### 4.1 使用 OpenClaw 内置 TTS

```bash
openclaw tts "你好，这是测试"
```

### 4.2 配置自定义 TTS

在 `~/.openclaw/openclaw.json` 中配置：

```json
{
  "tts": {
    "provider": "elevenlabs",
    "voice": "nova"
  }
}
```

### 4.3 发送语音消息

```python
from openclaw import message

message.send(
    channel="feishu",
    target="ou_xxx",
    text="你好",
    as_voice=True
)
```

---

## 5. 常见问题

### Q1: Whisper 模型下载失败

**问题**：网络无法访问 HuggingFace

**解决**：使用国内镜像
```bash
HF_ENDPOINT=https://hf-mirror.com pip install faster-whisper
```

### Q2: 飞书语音消息无法自动识别

**解决**：目前需要手动转文字，或配置本地 Whisper 自动化流程

### Q3: TTS 语音无法直接播放

**说明**：部分渠道可能以附件形式发送语音

---

## 6. 参考链接

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [飞书开发文档](https://open.feishu.cn/document)
- [faster-whisper GitHub](https://github.com/SYSTRAN/faster-whisper)
- [HuggingFace 国内镜像](https://hf-mirror.com)

---

*本文档由 OpenClaw 自动生成*
