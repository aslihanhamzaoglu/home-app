import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/app/app.dart';

void main() {
  testWidgets('the app starts with the terracotta Material 3 theme', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Ev');
    expect(app.theme!.useMaterial3, isTrue);
    expect(
      app.theme!.colorScheme,
      ColorScheme.fromSeed(seedColor: const Color(0xFFC8653D)),
    );
    expect(app.darkTheme!.colorScheme.brightness, Brightness.dark);
  });
}
