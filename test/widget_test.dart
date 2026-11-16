import 'package:flutter_test/flutter_test.dart';
import 'package:latianresponsi_movie/main.dart';

void main() {
  testWidgets('SpaceNewsApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpaceNewsApp(isLoggedIn: false));
    expect(find.byType(SpaceNewsApp), findsOneWidget);
  });
}
