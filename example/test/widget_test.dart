import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('App arranca correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const TilopayExampleApp());
    expect(find.text('Tilopay Demo'), findsOneWidget);
  });
}
