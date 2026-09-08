import 'package:flutter_test/flutter_test.dart';
import 'package:thabat/app.dart';

void main() {
  testWidgets('THABAT app builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ThabatApp());

    expect(find.byType(ThabatApp), findsOneWidget);
  });
}
