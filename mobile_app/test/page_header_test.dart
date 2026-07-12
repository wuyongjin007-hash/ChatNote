import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/widgets/page_header.dart';

void main() {
  testWidgets('centers a compact page title independently from the menu',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PageHeader(title: '语音记录')),
      ),
    );

    final screenCenter = tester.getCenter(find.byType(Scaffold)).dx;
    final titleCenter = tester.getCenter(find.text('语音记录')).dx;
    expect((titleCenter - screenCenter).abs(), lessThan(1));

    final title = tester.widget<Text>(find.text('语音记录'));
    expect(title.style?.fontSize, 18);
    expect(title.style?.fontWeight, FontWeight.w600);
  });
}
