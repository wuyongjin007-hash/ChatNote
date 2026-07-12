import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the ChatNote Android label and launcher mark', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final launcherIcon =
        File('android/app/src/main/res/drawable-nodpi/chatnote_launcher.png');

    expect(manifest, contains('android:label="ChatNote"'));
    expect(manifest, contains('android:icon="@drawable/chatnote_launcher"'));
    expect(launcherIcon.existsSync(), isTrue);
    expect(launcherIcon.lengthSync(), greaterThan(0));
  });
}
