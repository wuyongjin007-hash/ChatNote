import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/local_ai/local_voice_runtime.dart';

void main() {
  test('builds a Sherpa SenseVoice config for the ONNX model and token file',
      () {
    final config = buildSenseVoiceRecognizerConfig(
      modelPath: '/models/model_q8.onnx',
      tokensPath: '/models/tokens.txt',
    );

    expect(config.model.senseVoice.model, '/models/model_q8.onnx');
    expect(config.model.tokens, '/models/tokens.txt');
    expect(config.model.senseVoice.language, 'zh');
    expect(config.model.senseVoice.useInverseTextNormalization, isTrue);
  });
}
