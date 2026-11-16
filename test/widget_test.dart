import 'package:flutter_test/flutter_test.dart';
import 'package:latianresponsi_movie/main.dart';

void main() {
  testWidgets('MovieExplorerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieExplorerApp(isLoggedIn: false));
    expect(find.text('Movie Explorer'), findsOneWidget);
  });
}
