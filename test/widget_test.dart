import 'package:flutter_test/flutter_test.dart';

import 'package:accelle_studio/main.dart';

void main() {
  testWidgets('App boots to the dashboard tab', (WidgetTester tester) async {
    await tester.pumpWidget(const AccelleStudioApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Patterns'), findsOneWidget);
  });
}
