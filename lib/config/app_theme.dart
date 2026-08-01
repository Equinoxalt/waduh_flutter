import 'package:flutter/material.dart';

/// Warna dasar brand Waduh — diturunkan dari gradasi magenta-rose pada
/// logo, tapi dilunakkan (desaturasi + digelapkan) supaya kalem dan
/// profesional dipakai sebagai warna UI, bukan mencolok seperti gradien aslinya.
const Color brandSeedColor = Color(0xFF8C4B66);

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandSeedColor,
      brightness: Brightness.light,
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandSeedColor,
      brightness: Brightness.dark,
    ),
  );
}