# Qwen2.5 0.5B 本地 NLU 直接替换设计

## 目标

语音记录页的本地 NLU 从 Qwen3.5-0.8B Q4_K_M 直接替换为
Qwen2.5-0.5B-Instruct Q4_K_M，减少端侧推理等待时间，并继续完全离线运行。

## 锁定模型

- 上游：ModelScope `Qwen/Qwen2.5-0.5B-Instruct-GGUF`
- 文件：`qwen2.5-0.5b-instruct-q4_k_m.gguf`
- Revision：`2e50b77b0eee3083842019e257b74854323d880a`
- 大小：491,400,032 字节
- SHA-256：`74a4da8c9fdbcd15bd1f6d01d621410d31c6fc00986f5eb687824e7b93d7a9db`

## 运行与存储

本地模型目录仍然只有一个 NLU 槽位。模型清单中的 Qwen3.5 条目将被
Qwen2.5 条目替换；模型管理器初始化时会删除旧 Qwen3.5 NLU 目录及其未完成
下载文件。这样设置页只展示新模型，旧模型不会继续占用手机空间，也没有回退入口。

下载、断点续传、SHA-256 校验、原子安装以及 ASR/VAD 模型管理保持现有行为。

## 推理协议

llama.cpp Kotlin/JNI/C++ 桥继续复用。Dart 层的提示词改用 Qwen2.5 标准 ChatML：
`system -> user -> assistant`，移除 Qwen3.5 专用的 `<think>` 内容。现有严格 JSON
解析、金额事实归一化和规则降级继续保留，防止模型输出错误类别或字段时写入错误数据。

## 验证

更新模型清单和提示词相关单元测试；执行 `flutter analyze`、`flutter test` 和
`flutter build apk --debug`。真机在下载新模型后验证“语音识别 -> 本地 NLU ->
待办/想法/账目写入”。
