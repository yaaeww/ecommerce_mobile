import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_indramayu_mobile/main.dart';

void main() {
  testWidgets('App loads successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isApiConnected: true));
    await tester.pump(const Duration(milliseconds: 2000));

    // Verify that the app initializes properly
    expect(find.byType(MyApp), findsOneWidget);
  });
}
