# 手机端本地 AI 语音记录 — 技术方案调研报告

> 调研时间：2026-07-12 | 25 个来源 → 106 条声明 → 12 条经三方验证确认

---

## 一、推荐方案：双引擎架构

目前最成熟的方案是 **sherpa_onnx（ASR）+ flutter_gemma（NLU）** 双引擎：

```
麦克风 → sherpa_onnx (语音识别) → 文本 → flutter_gemma (信息提取) → 结构化数据
```

### 1. 语音识别：sherpa_onnx（首选）

| 指标 | 数据 |
|------|------|
| pub.dev 评分 | 120/160，v1.13.4，GitHub 7.8K+ stars |
| 集成方式 | Dart FFI 封装 ONNX Runtime |
| 平台支持 | Android arm64 ✅ / iOS arm64 ✅ |
| 识别模式 | 流式 + 非流式，完全离线 |
| 附带能力 | Silero VAD（语音活动检测） |

**中文 ASR 模型选择：**

| 模型 | 体积 | 适用场景 |
|------|------|----------|
| SenseVoiceSmall | ~80MB | 多语言(zh/en/ja/ko/yue)+方言+情绪标签，CER 7.81% |
| streaming-zipformer-bilingual-zh-en | ~80MB | 中英双语流式识别 |
| streaming-zipformer-zh-14M | ~14MB | Cortex A7 等低端 CPU |
| Paraformer zh | ~80MB | 通用中文 |

**实测性能**（BrightCoding 2025，iPhone 15 Pro）：流式 ASR RTF 0.05，约 45MB 内存，电池消耗 <1%/小时。

> ⚠️ sherpa_onnx 是纯语音处理框架，**不提供 NLU/意图分类/实体抽取**能力。

### 2. 文本理解：flutter_gemma

| 指标 | 数据 |
|------|------|
| pub.dev 评分 | 120/160，v1.2.3，活跃维护 |
| Function Calling | ✅ 支持 Tool、ToolChoice、ParallelFunctionCallResponse |
| 支持模型 | Gemma 4、Gemma 3 1B、FunctionGemma、Qwen3、Qwen 2.5、DeepSeek、Phi-4 |

可通过定义 JSON Schema 工具从转录文本中结构化提取待办、想法、账目等信息。

---

## 二、备选方案

| 方案 | ASR | NLU | 优势 | 风险 |
|------|-----|-----|------|------|
| **edge_veda** | whisper.cpp | llama.cpp | 一体化(ASR+LLM+RAG)、Isolate 架构不阻塞 UI | 社区极小(18 likes, 67 stars)、性能声明被三方证伪 |
| **CrisperWeaver** | CrispASR(43种模型) | GGUF LLM | 完整开源 App 可参考 | 个人项目、无三方验证、NLU 声明被证伪 |
| **whisper_ggml_plus** | Whisper.cpp v1.8.3 | ❌ 无 | pub.dev 160/160 满分 | **仅支持文件级识别，不支持流式** |
| **flutter_litert** | ❌ 无 | ❌ 无 | 推理引擎 | 纯视觉任务，无 ASR/NLU 模型 |

---

## 三、工程落地关键约束

根据实际评测数据：

| 设备档次 | 推荐模型 | 内存占用 | 推理速度 |
|----------|---------|---------|----------|
| 旗舰 (8GB+ RAM) | SenseVoiceSmall + Gemma-3 1B | ASR ~50MB + NLU ~1.5GB | ASR 实时、NLU 10-20 tok/s |
| 中端 (6GB RAM) | Zipformer-zh-14M + FunctionGemma 270M | ASR ~14MB + NLU ~600MB | 可用 |
| 低端 (4GB RAM) | 系统内置 ASR + 规则匹配 | — | 仅推荐方案 |

**量化策略**：INT4 量化可将 5.1B 模型从 19.3GB 压缩到 3.2GB，解码吞吐提升 13x（Arm 官方数据）。

---

## 四、与当前架构的集成路径

当前项目已有的 `speechChannelProvider` 可以替换为 sherpa_onnx 的 `OfflineRecognizer`：

```dart
// 当前: 系统语音识别
ref.read(speechChannelProvider).startRecognition();

// 替换为: sherpa_onnx 本地识别
final recognizer = OfflineRecognizer(config);
final stream = recognizer.createStream();
stream.acceptWaveform(audioSamples);
final result = recognizer.decode(stream);
```

NLU 环节可以用 flutter_gemma 的 Function Calling 替代当前的 `CaptureConversationAgent` 云端调用。

---

## 五、待验证的关键问题

1. **sherpa_onnx + flutter_gemma 双引擎同时加载**对 6-8GB RAM 设备的内存叠加效应如何？
2. **SenseVoiceSmall 在手机 CPU** 上的实际 RTF/CER 是多少？
3. **FunctionGemma 270M / Gemma-3 1B** 在中文信息提取上的 Function Calling 准确率？
4. **iOS App Store 部署**需手动将 dylib 转为 xcframework

---

## 六、建议落地路线

1. **第一阶段**：仅替换 ASR 为 sherpa_onnx（SenseVoiceSmall），保持 NLU 走云端，验证端侧语音识别效果
2. **第二阶段**：引入 flutter_gemma + FunctionGemma 270M 做端侧信息提取，与云端效果做 A/B 对比
3. **第三阶段**：全链路端侧化，云端仅做备份/复杂查询

**核心结论**：端侧语音记录在技术上是完全可行的。ASR 方案（sherpa_onnx）已经成熟，NLU 方案（flutter_gemma）有可用 API 但实际中文效果需自行验证。建议先做 ASR 端侧化，这是风险最低、收益最大的第一步。

---

## 主要参考来源

- [sherpa_onnx - pub.dev](https://pub.dev/packages/sherpa_onnx)
- [flutter_gemma - pub.dev](https://pub.dev/packages/flutter_gemma)
- [FunASR 中文 ASR Benchmark](https://modelscope.github.io/FunASR/zh/benchmark.html)
- [Sherpa-ONNX PR #2705 - Flutter demo](https://github.com/k2-fsa/sherpa-onnx/pull/2705)
- [edge_veda - pub.dev](https://pub.dev/packages/edge_veda)
- [CrisperWeaver - GitHub](https://github.com/CrispStrobe/CrisperWeaver)
- [whisper_ggml_plus - GitHub](https://github.com/DDULDDUCK/whisper_ggml_plus)
