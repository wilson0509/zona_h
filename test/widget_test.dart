// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zona_h/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verifica que el texto esperado está renderizado en un widget de texto.
    expect(find.text('Bienvenido a Zona H'), findsOneWidget);

    // Simulación de un tap.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica que el conteo de taps incrementa.
    expect(find.text('1'), findsOneWidget);
  });
}
