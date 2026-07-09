import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _arkApiKeyController = TextEditingController();
  final _arkBaseUrlController = TextEditingController();
  final _arkSpeechModelController = TextEditingController();
  final _arkTextModelController = TextEditingController();
  bool _loaded = false;
  bool _databaseEncryption = false;

  @override
  void dispose() {
    _arkApiKeyController.dispose();
    _arkBaseUrlController.dispose();
    _arkSpeechModelController.dispose();
    _arkTextModelController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loaded) {
      return;
    }
    final settings = ref.read(settingsStoreProvider);
    _arkApiKeyController.text = await settings.volcengineArkApiKey() ?? '';
    _arkBaseUrlController.text = await settings.volcengineArkBaseUrl();
    _arkSpeechModelController.text = await settings.volcengineArkSpeechModel();
    _arkTextModelController.text = await settings.volcengineArkTextModel();
    _databaseEncryption = await settings.databaseEncryptionEnabled();
    _loaded = true;
  }

  Future<void> _save() async {
    final settings = ref.read(settingsStoreProvider);
    await settings.setVolcengineArkApiKey(_arkApiKeyController.text);
    await settings.setVolcengineArkBaseUrl(_arkBaseUrlController.text);
    await settings.setVolcengineArkSpeechModel(_arkSpeechModelController.text);
    await settings.setVolcengineArkTextModel(_arkTextModelController.text);
    await settings.setDatabaseEncryptionEnabled(_databaseEncryption);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('设置已保存')));
  }

  Future<void> _clearData() async {
    await ref.read(entryRepositoryProvider).clearAll();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('本地数据已清空')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load(),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: ListView(
            children: [
              Text('设置', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: _arkApiKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '火山方舟 API Key',
                  hintText: 'ARK_API_KEY',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _arkBaseUrlController,
                decoration: const InputDecoration(
                  labelText: '火山方舟 Base URL',
                  hintText: 'https://ark.cn-beijing.volces.com/api/v3',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _arkSpeechModelController,
                decoration: const InputDecoration(
                  labelText: '语音理解模型 ID',
                  hintText: 'doubao-seed-2-0-lite-260428',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _arkTextModelController,
                decoration: const InputDecoration(
                  labelText: '文本生成模型 ID',
                  hintText: 'doubao-seed-2-1-pro-260628',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _databaseEncryption,
                title: const Text('启用数据库加密'),
                subtitle: const Text('当前为预留开关；接入 SQLCipher 后生效。'),
                onChanged: (value) => setState(() => _databaseEncryption = value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('保存设置'),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _clearData,
                icon: const Icon(Icons.delete_outline),
                label: const Text('清空本地数据'),
              ),
              const SizedBox(height: 12),
              const Text(
                '说明：待办、创意、搜索索引只存储在手机本地 SQLite。语音理解按 Files API 上传录音到火山方舟，再用 file_id 调 Responses API；语义整理使用同一套火山方舟 API Key 调 Chat Completions。',
              ),
            ],
          ),
        );
      },
    );
  }
}
