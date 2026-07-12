import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/audio/interaction_sound_service.dart';

void main() {
  test('uses media player mode for in-memory WAV sounds on Android', () {
    expect(
      LocalInteractionSoundService.playbackMode,
      PlayerMode.mediaPlayer,
    );
  });
}
