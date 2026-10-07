import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar_app/main.dart';

void main() {
  testWidgets('VanRozgar opens with statewide sign-in entry', (tester) async {
    await tester.pumpWidget(const VanRozgarApp());
    await tester.pumpAndSettle();

    expect(find.text('VanRozgar 2.0'), findsOneWidget);
    expect(find.textContaining('Maharashtra'), findsOneWidget);
    expect(find.textContaining('Sign in to Get Started'), findsOneWidget);
  });

  testWidgets('guest can enter the demo without phone authentication',
      (tester) async {
    await tester.pumpWidget(const VanRozgarApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Explore as Guest'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Choose Village'), findsOneWidget);
    expect(find.textContaining('Talavade'), findsWidgets);
  });
}
