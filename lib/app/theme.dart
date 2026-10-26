import 'package:flutter/material.dart';

const _terracotta = Color(0xFFC8653D);

final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _terracotta),
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _terracotta,
    brightness: Brightness.dark,
  ),
);
