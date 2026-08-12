import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/main.dart';

void main() {
  testWidgets('opens branded splash screen', (tester) async {
    await tester.pumpWidget(const KomekciApp());
    expect(find.text('KÖMEKÇI'), findsOneWidget);
    expect(find.text('Baglanyşyk barlanýar...'), findsOneWidget);
  });
}
