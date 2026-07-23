import 'package:flutter/material.dart';

class PaymentMethodInfo {
  const PaymentMethodInfo._();

  static const int cash = 1;
  static const int card = 2;
  static const int transfer = 3;

  /// Normaliza el método de pago a su código entero (acepta num o texto).
  static int normalize(dynamic method) {
    if (method is num) return method.toInt();
    final s = method?.toString().toLowerCase().trim();
    if (s == '2' || s == 'tarjeta' || s == 'card') return card;
    if (s == '3' || s == 'transferencia' || s == 'transfer' || s == 'spei') {
      return transfer;
    }
    return cash;
  }

  static bool isCash(dynamic method) => normalize(method) == cash;
  static bool isCard(dynamic method) => normalize(method) == card;
  static bool isTransfer(dynamic method) => normalize(method) == transfer;

  /// Pagos electrónicos donde el cliente paga por su cuenta (tarjeta o
  /// transferencia): el conductor espera la confirmación en vez de cobrar
  /// en efectivo de mano.
  static bool isElectronic(dynamic method) =>
      isCard(method) || isTransfer(method);

  static String label(dynamic method) {
    switch (normalize(method)) {
      case card:
        return 'Tarjeta';
      case transfer:
        return 'Transferencia';
      default:
        return 'Efectivo';
    }
  }

  static IconData icon(dynamic method) {
    switch (normalize(method)) {
      case card:
        return Icons.credit_card_rounded;
      case transfer:
        return Icons.account_balance_outlined;
      default:
        return Icons.payments_outlined;
    }
  }
}

class PaymentStatusInfo {
  const PaymentStatusInfo._();

  static const int pending = 1;
  static const int paid = 2;

  static bool isPaid(dynamic status) =>
      status is num && status.toInt() == paid;
}
