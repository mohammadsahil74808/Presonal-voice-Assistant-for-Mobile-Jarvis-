import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_mobile/app/app.dart';

void main() {
  testWidgets('JARVIS initial UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JarvisApp());

    // Verify that JARVIS title exists.
    expect(find.text('JARVIS'), findsOneWidget);
  });
}
