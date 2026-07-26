import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local_ai/local_model_manager.dart';
import '../../providers.dart';
import '../../settings/settings_store.dart';
import '../../widgets/page_header.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKey = TextEditingController();
  final _baseUrl = TextEditingController();
  final _speechModel = TextEditingController();
  final _textModel = TextEditingController();
  final _deepSeekApiKey = TextEditingController();
  final _deepSeekBaseUrl = TextEditingController();
  String _deepSeekModel = 'deepseek-v4-flash';
  VoiceCaptureProvider _voiceCaptureProvider =
      VoiceCaptureProvider.volcengineArk;
  bool _loaded = false;
  bool _databaseEncryption = false;

  @override
  void dispose() {
    _apiKey.dispose();
    _baseUrl.dispose();
    _speechModel.dispose();
    _textModel.dispose();
    _deepSeekApiKey.dispose();
    _deepSeekBaseUrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loaded) return;
    final settings = ref.read(settingsStoreProvider);
    _apiKey.text = await settings.volcengineArkApiKey() ?? '';
    _baseUrl.text = await settings.volcengineArkBaseUrl();
    _speechModel.text = await settings.volcengineArkSpeechModel();
    _textModel.text = await settings.volcengineArkTextModel();
    _deepSeekApiKey.text = await settings.deepSeekApiKey() ?? '';
    _deepSeekBaseUrl.text = await settings.deepSeekBaseUrl();
    _deepSeekModel = await settings.deepSeekTextModel();
    _voiceCaptureProvider = await settings.voiceCaptureProvider();
    _databaseEncryption = await settings.databaseEncryptionEnabled();
    _loaded = true;
  }

  Future<void> _save() async {
    final settings = ref.read(settingsStoreProvider);
    await settings.setVolcengineArkApiKey(_apiKey.text);
    await settings.setVolcengineArkBaseUrl(_baseUrl.text);
    await settings.setVolcengineArkSpeechModel(_speechModel.text);
    await settings.setVolcengineArkTextModel(_textModel.text);
    await settings.setDeepSeekApiKey(_deepSeekApiKey.text);
    await settings.setDeepSeekBaseUrl(_deepSeekBaseUrl.text);
    await settings.setDeepSeekTextModel(_deepSeekModel);
    await settings.setVoiceCaptureProvider(_voiceCaptureProvider);
    await settings.setDatabaseEncryptionEnabled(_databaseEncryption);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('云端配置已保存')));
    }
  }

  Future<void> _clearData() async {
    await ref.read(entryRepositoryProvider).clearAll();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('本地数据已清空')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load(),
      builder: (context, _) => DefaultTabController(
        length: 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(children: [
            const PageHeader(title: '设置'),
            const SizedBox(height: 10),
            const TabBar(tabs: [Tab(text: '云端配置'), Tab(text: '离线模型')]),
            const SizedBox(height: 8),
            Expanded(
                child: TabBarView(children: [
              _CloudSettings(
                apiKey: _apiKey,
                baseUrl: _baseUrl,
                speechModel: _speechModel,
                textModel: _textModel,
                deepSeekApiKey: _deepSeekApiKey,
                deepSeekBaseUrl: _deepSeekBaseUrl,
                deepSeekModel: _deepSeekModel,
                voiceCaptureProvider: _voiceCaptureProvider,
                onVoiceCaptureProviderChanged: (value) =>
                    setState(() => _voiceCaptureProvider = value),
                onDeepSeekModelChanged: (value) =>
                    setState(() => _deepSeekModel = value),
                encryption: _databaseEncryption,
                onEncryptionChanged: (value) =>
                    setState(() => _databaseEncryption = value),
                onSave: _save,
                onClear: _clearData,
              ),
              _OfflineModelsTab(manager: ref.read(localModelManagerProvider)),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _CloudSettings extends StatelessWidget {
  const _CloudSettings(
      {required this.apiKey,
      required this.baseUrl,
      required this.speechModel,
      required this.textModel,
      required this.deepSeekApiKey,
      required this.deepSeekBaseUrl,
      required this.deepSeekModel,
      required this.voiceCaptureProvider,
      required this.onVoiceCaptureProviderChanged,
      required this.onDeepSeekModelChanged,
      required this.encryption,
      required this.onEncryptionChanged,
      required this.onSave,
      required this.onClear});
  final TextEditingController apiKey, baseUrl, speechModel, textModel;
  final TextEditingController deepSeekApiKey, deepSeekBaseUrl;
  final String deepSeekModel;
  final VoiceCaptureProvider voiceCaptureProvider;
  final ValueChanged<VoiceCaptureProvider> onVoiceCaptureProviderChanged;
  final ValueChanged<String> onDeepSeekModelChanged;
  final bool encryption;
  final ValueChanged<bool> onEncryptionChanged;
  final VoidCallback onSave, onClear;

  @override
  Widget build(BuildContext context) => ListView(children: [
        const SizedBox(height: 12),
        const Text('智能记录（固定使用火山方舟）',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextField(
            controller: apiKey,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: '火山方舟 API Key', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(
            controller: baseUrl,
            decoration: const InputDecoration(
                labelText: '火山方舟 Base URL', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(
            controller: speechModel,
            decoration: const InputDecoration(
                labelText: '方舟语音模型 ID（预留）', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(
            controller: textModel,
            decoration: const InputDecoration(
                labelText: '方舟文本模型 ID', border: OutlineInputBorder())),
        const SizedBox(height: 24),
        const Text('语音记录云端整理', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        DropdownButtonFormField<VoiceCaptureProvider>(
          key: const Key('voice-capture-provider'),
          initialValue: voiceCaptureProvider,
          decoration: const InputDecoration(
              labelText: '语言模型提供商', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(
              value: VoiceCaptureProvider.volcengineArk,
              child: Text('火山方舟'),
            ),
            DropdownMenuItem(
              value: VoiceCaptureProvider.deepSeek,
              child: Text('DeepSeek'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onVoiceCaptureProviderChanged(value);
          },
        ),
        if (voiceCaptureProvider == VoiceCaptureProvider.deepSeek) ...[
          const SizedBox(height: 12),
          TextField(
            controller: deepSeekApiKey,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'DeepSeek API Key',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: deepSeekBaseUrl,
            decoration: const InputDecoration(
              labelText: 'DeepSeek Base URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: deepSeekModel,
            decoration: const InputDecoration(
              labelText: 'DeepSeek 文本模型',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'deepseek-v4-flash',
                child: Text('deepseek-v4-flash'),
              ),
              DropdownMenuItem(
                value: 'deepseek-v4-pro',
                child: Text('deepseek-v4-pro'),
              ),
            ],
            onChanged: (value) {
              if (value != null) onDeepSeekModelChanged(value);
            },
          ),
        ],
        SwitchListTile(
            value: encryption,
            onChanged: onEncryptionChanged,
            title: const Text('启用数据库加密'),
            subtitle: const Text('预留开关，接入 SQLCipher 后生效。')),
        FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            label: const Text('保存云端配置')),
        const SizedBox(height: 24),
        OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline),
            label: const Text('清空本地数据')),
        const SizedBox(height: 12),
        const Text(
            '智能记录固定使用火山方舟 Responses API。语音记录可选火山方舟或 DeepSeek，并且只上传本地转写文字，不上传录音。'),
      ]);
}

class _OfflineModelsTab extends StatefulWidget {
  const _OfflineModelsTab({required this.manager});
  final LocalModelManager manager;
  @override
  State<_OfflineModelsTab> createState() => _OfflineModelsTabState();
}

class _OfflineModelsTabState extends State<_OfflineModelsTab> {
  @override
  void initState() {
    super.initState();
    widget.manager.initialize();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<LocalModelStatus>>(
        stream: widget.manager.changes,
        initialData: widget.manager.statuses,
        builder: (context, snapshot) => ListView(children: [
          const Padding(
              padding: EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text('此处只管理语音识别模型。语音记录页优先本地规则，必要时才使用云端文字模型。')),
          for (final model in snapshot.data ?? widget.manager.statuses)
            _ModelCard(model: model, manager: widget.manager),
        ]),
      );
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.model, required this.manager});
  final LocalModelStatus model;
  final LocalModelManager manager;
  @override
  Widget build(BuildContext context) {
    final downloading = model.state == LocalModelInstallState.downloading;
    final verifying = model.state == LocalModelInstallState.verifying;
    final label = model.spec.bytes == 0
        ? '待锁定'
        : '${(model.spec.bytes / 1024 / 1024).toStringAsFixed(0)} MB';
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(model.spec.name,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                  '${model.spec.source}\n版本：${model.spec.version}\n大小：$label · 最低内存：${model.spec.minimumRamGb}GB'),
              const SizedBox(height: 10),
              if (downloading || verifying) ...[
                LinearProgressIndicator(
                    value: downloading ? model.progress : null),
                const SizedBox(height: 6),
                Text(verifying
                    ? '正在校验 SHA-256…'
                    : '已下载 ${(model.downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB'),
              ] else
                Text(model.isReady
                    ? '已下载并通过 SHA-256 校验'
                    : model.error ?? '尚未下载'),
              if (model.error != null)
                Text(model.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              Row(children: [
                if (downloading)
                  OutlinedButton(
                      onPressed: () => manager.cancel(model.spec),
                      child: const Text('取消'))
                else if (model.isReady)
                  OutlinedButton(
                      onPressed: () => manager.delete(model.spec),
                      child: const Text('删除'))
                else
                  FilledButton(
                      onPressed:
                          verifying ? null : () => manager.download(model.spec),
                      child: Text(model.error == null ? '下载' : '重试')),
                const SizedBox(width: 8),
                TextButton(
                    onPressed: manager.initialize, child: const Text('检查状态')),
              ]),
            ])));
  }
}
