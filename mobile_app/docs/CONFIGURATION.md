# 配置指南

本仓库不包含 API Key、本地模型文件或用户数据。安装 App 后，请从
**设置 → 云端配置** 完成云端服务配置。凭据将通过 Flutter Secure Storage
保存在设备上，不会被写入仓库或 APK 源码。

## 智能记录：火山方舟

智能记录使用火山方舟的 Responses API 实现多轮对话与本地工具调用。

1. 打开 **设置 → 云端配置**。
2. 填写火山方舟 API Key、Base URL 和文本模型 ID。
3. 保存配置。

默认 Base URL：`https://ark.cn-beijing.volces.com/api/v3`。

## 语音记录：选择方舟或 DeepSeek

语音记录使用 SenseVoice 在本地完成语音转文字；只有识别后的文本会被发送到
所选云端模型进行结构化整理，录音文件不会上传。

- **火山方舟**：使用上方填写的方舟 API Key、Base URL 和文本模型。
- **DeepSeek**：在“语音记录云端整理”中选择 **DeepSeek**，再填写独立的
  API Key。默认 Base URL 为 `https://api.deepseek.com`；可选预设模型为
  `deepseek-v4-flash` 与 `deepseek-v4-pro`。

## 本地语音模型

在 **离线模型** 标签页中，通过 Wi-Fi 下载 SenseVoice 和 FSMN-VAD。模型文件
仅保存在 App 私有存储中，不会被纳入 Git。

## 可选的开发期兜底配置

仅供本地开发时使用，可通过 Dart 的构建期参数提供方舟 Key：

```powershell
flutter run --dart-define=VOLCENGINE_ARK_API_KEY=your_key_here
```

不要提交真实 Key，也不要将它写入 `local_config.dart`、README、Issue、截图或
构建产物。日常使用请优先通过 App 内设置页填写凭据。
