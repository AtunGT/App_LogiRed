import 'package:intl/intl.dart';

class Money {
  const Money._();

  static final _whole = NumberFormat('#,##0', 'en_US');
  static final _cents = NumberFormat('#,##0.00', 'en_US');

  static String format(double v) {
    final hasCents = (v - v.truncateToDouble()).abs() > 0.004;
    return '\$${(hasCents ? _cents : _whole).format(v)}';
  }

  static String mxn(double v) => '${format(v)} MXN';

  /// Con signo explícito: "+$450" / "−$50".
  static String signed(double v) =>
      v < 0 ? '−${format(v.abs())}' : '+${format(v)}';
}
