import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vanrozgar_app/providers/app_state_provider.dart';
import 'package:vanrozgar_app/screens/what_if_simulator_screen.dart';

void main() {
  testWidgets('simulator selects an available village resource by default',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStateProvider(),
        child: const MaterialApp(home: WhatIfSimulatorScreen()),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Perennial Pond'), findsOneWidget);
  });
}
