import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1d6b50),
      surfaceTint: Color(0xff1d6b50),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa7f2d0),
      onPrimaryContainer: Color(0xff00513a),
      secondary: Color(0xff006875),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff9eefff),
      onSecondaryContainer: Color(0xff004e59),
      tertiary: Color(0xff006874),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff9eeffd),
      onTertiaryContainer: Color(0xff004f58),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fbf6),
      onSurface: Color(0xff171d1a),
      onSurfaceVariant: Color(0xff3f484a),
      outline: Color(0xff6f797a),
      outlineVariant: Color(0xffbfc8ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b322f),
      inversePrimary: Color(0xff8cd5b4),
      primaryFixed: Color(0xffa7f2d0),
      onPrimaryFixed: Color(0xff002115),
      primaryFixedDim: Color(0xff8cd5b4),
      onPrimaryFixedVariant: Color(0xff00513a),
      secondaryFixed: Color(0xff9eefff),
      onSecondaryFixed: Color(0xff001f24),
      secondaryFixedDim: Color(0xff82d3e2),
      onSecondaryFixedVariant: Color(0xff004e59),
      tertiaryFixed: Color(0xff9eeffd),
      onTertiaryFixed: Color(0xff001f24),
      tertiaryFixedDim: Color(0xff82d3e0),
      onTertiaryFixedVariant: Color(0xff004f58),
      surfaceDim: Color(0xffd5dbd7),
      surfaceBright: Color(0xfff5fbf6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f1),
      surfaceContainer: Color(0xffe9efeb),
      surfaceContainerHigh: Color(0xffe3eae5),
      surfaceContainerHighest: Color(0xffdee4e0),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003f2c),
      surfaceTint: Color(0xff1d6b50),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff307a5e),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003c45),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff1a7886),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003c44),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff187884),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf6),
      onSurface: Color(0xff0c1210),
      onSurfaceVariant: Color(0xff2f3839),
      outline: Color(0xff4b5456),
      outlineVariant: Color(0xff656f70),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b322f),
      inversePrimary: Color(0xff8cd5b4),
      primaryFixed: Color(0xff307a5e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0e6146),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff1a7886),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff005e6a),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff187884),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff005e68),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c8c4),
      surfaceBright: Color(0xfff5fbf6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f1),
      surfaceContainer: Color(0xffe3eae5),
      surfaceContainerHigh: Color(0xffd8deda),
      surfaceContainerHighest: Color(0xffcdd3cf),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003323),
      surfaceTint: Color(0xff1d6b50),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00543c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003138),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff00515c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003238),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00515a),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e2f),
      outlineVariant: Color(0xff414b4c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b322f),
      inversePrimary: Color(0xff8cd5b4),
      primaryFixed: Color(0xff00543c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003b29),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff00515c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff003940),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff00515a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff00393f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4bab6),
      surfaceBright: Color(0xfff5fbf6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2ee),
      surfaceContainer: Color(0xffdee4e0),
      surfaceContainerHigh: Color(0xffd0d6d2),
      surfaceContainerHighest: Color(0xffc2c8c4),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8cd5b4),
      surfaceTint: Color(0xff8cd5b4),
      onPrimary: Color(0xff003827),
      primaryContainer: Color(0xff00513a),
      onPrimaryContainer: Color(0xffa7f2d0),
      secondary: Color(0xff82d3e2),
      onSecondary: Color(0xff00363e),
      secondaryContainer: Color(0xff004e59),
      onSecondaryContainer: Color(0xff9eefff),
      tertiary: Color(0xff82d3e0),
      onTertiary: Color(0xff00363d),
      tertiaryContainer: Color(0xff004f58),
      onTertiaryContainer: Color(0xff9eeffd),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffdee4e0),
      onSurfaceVariant: Color(0xffbfc8ca),
      outline: Color(0xff899294),
      outlineVariant: Color(0xff3f484a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4e0),
      inversePrimary: Color(0xff1d6b50),
      primaryFixed: Color(0xffa7f2d0),
      onPrimaryFixed: Color(0xff002115),
      primaryFixedDim: Color(0xff8cd5b4),
      onPrimaryFixedVariant: Color(0xff00513a),
      secondaryFixed: Color(0xff9eefff),
      onSecondaryFixed: Color(0xff001f24),
      secondaryFixedDim: Color(0xff82d3e2),
      onSecondaryFixedVariant: Color(0xff004e59),
      tertiaryFixed: Color(0xff9eeffd),
      onTertiaryFixed: Color(0xff001f24),
      tertiaryFixedDim: Color(0xff82d3e0),
      onTertiaryFixedVariant: Color(0xff004f58),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff343b38),
      surfaceContainerLowest: Color(0xff090f0d),
      surfaceContainerLow: Color(0xff171d1a),
      surfaceContainer: Color(0xff1b211e),
      surfaceContainerHigh: Color(0xff252b29),
      surfaceContainerHighest: Color(0xff303633),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa1ecca),
      surfaceTint: Color(0xff8cd5b4),
      onPrimary: Color(0xff002c1e),
      primaryContainer: Color(0xff569e80),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xff98e9f8),
      onSecondary: Color(0xff002a31),
      secondaryContainer: Color(0xff499caa),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff98e9f7),
      onTertiary: Color(0xff002a30),
      tertiaryContainer: Color(0xff499ca9),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd4dee0),
      outline: Color(0xffaab4b5),
      outlineVariant: Color(0xff889294),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4e0),
      inversePrimary: Color(0xff00533b),
      primaryFixed: Color(0xffa7f2d0),
      onPrimaryFixed: Color(0xff00150c),
      primaryFixedDim: Color(0xff8cd5b4),
      onPrimaryFixedVariant: Color(0xff003f2c),
      secondaryFixed: Color(0xff9eefff),
      onSecondaryFixed: Color(0xff001418),
      secondaryFixedDim: Color(0xff82d3e2),
      onSecondaryFixedVariant: Color(0xff003c45),
      tertiaryFixed: Color(0xff9eeffd),
      onTertiaryFixed: Color(0xff001417),
      tertiaryFixedDim: Color(0xff82d3e0),
      onTertiaryFixedVariant: Color(0xff003c44),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff3f4643),
      surfaceContainerLowest: Color(0xff040807),
      surfaceContainerLow: Color(0xff191f1c),
      surfaceContainer: Color(0xff232927),
      surfaceContainerHigh: Color(0xff2e3431),
      surfaceContainerHighest: Color(0xff393f3c),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb8ffde),
      surfaceTint: Color(0xff8cd5b4),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff88d1b0),
      onPrimaryContainer: Color(0xff000e08),
      secondary: Color(0xffd0f7ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff7ecfde),
      onSecondaryContainer: Color(0xff000d11),
      tertiary: Color(0xffcdf7ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff7ecfdc),
      onTertiaryContainer: Color(0xff000e10),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2f3),
      outlineVariant: Color(0xffbbc4c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4e0),
      inversePrimary: Color(0xff00533b),
      primaryFixed: Color(0xffa7f2d0),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8cd5b4),
      onPrimaryFixedVariant: Color(0xff00150c),
      secondaryFixed: Color(0xff9eefff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff82d3e2),
      onSecondaryFixedVariant: Color(0xff001418),
      tertiaryFixed: Color(0xff9eeffd),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff82d3e0),
      onTertiaryFixedVariant: Color(0xff001417),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff4b514e),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b211e),
      surfaceContainer: Color(0xff2b322f),
      surfaceContainerHigh: Color(0xff363d3a),
      surfaceContainerHighest: Color(0xff424845),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
