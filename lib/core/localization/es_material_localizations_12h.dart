import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Localización de Material en español idéntica a la de Flutter, pero con el
/// formato de hora en **12 horas con AM/PM** en lugar de 24 horas.
///
/// Flutter fija el español a 24h a nivel de idioma: `MaterialLocalizationEs`
/// devuelve `TimeOfDayFormat.H_colon_mm`, y ningún país (`es_MX`, `es_CO`, …)
/// lo cambia. Esta subclase solo sobrescribe ese formato para que el selector
/// de hora muestre 12h con AM/PM (a. m. / p. m.), manteniendo el resto de los
/// textos en español.
class _MaterialLocalizationEs12h extends MaterialLocalizationEs {
  const _MaterialLocalizationEs12h({
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.h_colon_mm_space_a;
}

/// Delegado que reemplaza a [GlobalMaterialLocalizations.delegate] para el
/// español, entregando [_MaterialLocalizationEs12h] (12h con AM/PM).
class EsMaterialLocalizations12hDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const EsMaterialLocalizations12hDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'es';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final String canonical = intl.Intl.canonicalizedLocale(locale.toString());
    final String name =
        intl.DateFormat.localeExists(canonical) ? canonical : 'es';
    return SynchronousFuture<MaterialLocalizations>(
      _MaterialLocalizationEs12h(
        fullYearFormat: intl.DateFormat.y(name),
        compactDateFormat: intl.DateFormat.yMd(name),
        shortDateFormat: intl.DateFormat.yMMMd(name),
        mediumDateFormat: intl.DateFormat.MMMEd(name),
        longDateFormat: intl.DateFormat.yMMMMEEEEd(name),
        yearMonthFormat: intl.DateFormat.yMMMM(name),
        shortMonthDayFormat: intl.DateFormat.MMMd(name),
        decimalFormat: intl.NumberFormat.decimalPattern(name),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', name),
      ),
    );
  }

  @override
  bool shouldReload(EsMaterialLocalizations12hDelegate old) => false;
}
