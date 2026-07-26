import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/local_ai/local_model_manager.dart';

void main() {
  test('contains only local speech-recognition model artifacts', () {
    expect(LocalModelCatalog.all, hasLength(3));
    expect(
      LocalModelCatalog.all.map((model) => model.kind).toSet(),
      {LocalModelKind.asr, LocalModelKind.asrTokens, LocalModelKind.vad},
    );
  });

  test('locks the ModelScope sherpa SenseVoice Q8 ONNX artifact', () {
    final asr = LocalModelCatalog.senseVoice;
    final tokens = LocalModelCatalog.senseVoiceTokens;

    expect(asr.fileName, 'model_q8.onnx');
    expect(asr.version, '1faa169e9bc83503acb1b41541b26de8aaa8fe0f');
    expect(asr.bytes, 239234116);
    expect(
      asr.sha256,
      '6887cdd6fc94c3e4cb5aea8b62dead45229643708d20b8ec8a4a736dfb45f6af',
    );
    expect(tokens.fileName, 'tokens.txt');
    expect(tokens.version, '4c244d4b1a7a93539c408d61de4bbcf0966ac39f');
    expect(tokens.bytes, 315894);
    expect(
      tokens.sha256,
      'f449eb28dc567533d7fa59be34e2abca8784f771850c78a47fb731a31429a1dc',
    );
    expect(
      LocalModelCatalog.all.map((model) => model.id),
      [
        asr.id,
        tokens.id,
        LocalModelCatalog.fsmnVad.id,
      ],
    );
  });
}
