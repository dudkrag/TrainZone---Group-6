import 'package:flutter_test/flutter_test.dart';
import 'package:footballtracking_app/main.dart';

void main() {
  testWidgets('App builds (smoke test)', (WidgetTester tester) async {
    await tester.pumpWidget(const MovesenseApp());

    // Hvis appen bygger uden exceptions, er testen OK.
    expect(find.byType(MovesenseApp), findsOneWidget);
  });
}
