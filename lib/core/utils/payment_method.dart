import 'package:flutter/material.dart';

class PaymentMethodInfo {
  const PaymentMethodInfo._();

  static const int cash = 1;
  static const int card = 2;

  static bool isCard(dynamic method) {
    if (method is num) return method.toInt() == card;
    final s = method?.toString().toLowerCase().trim();
    return s == '2' || s == 'tarjeta';
  }

  static String label(dynamic method) =>
      isCard(method) ? 'Tarjeta' : 'Efectivo';

  static IconData icon(dynamic method) =>
      isCard(method) ? Icons.credit_card_rounded : Icons.payments_outlined;
}

/// Estado de pago del viaje (columna `payment_status` de rides).
class PaymentStatusInfo {
  const PaymentStatusInfo._();

  static const int pending = 1;
  static const int paid = 2;

  static bool isPaid(dynamic status) =>
      status is num && status.toInt() == paid;
}
