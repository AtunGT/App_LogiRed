import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/model/models.dart';
import '../../../core/state/view_state.dart';

enum WalletPeriod { day, month }

class DriverWalletProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;

  DriverWalletProvider(this._api);

  static const _pageSize = 20;

  bool isLoadingMore = false;

  String? partialError;
  bool _loadedOnce = false;

  DriverWallet wallet = DriverWallet();

  WalletPeriod period = WalletPeriod.day;
  List<WalletSummaryEntry> _summaryDay = [];
  List<WalletSummaryEntry> _summaryMonth = [];
  bool _monthLoaded = false;

  List<WalletMovement> movements = [];
  int totalMovements = 0;
  int _page = 1;

  bool get hasMore => movements.length < totalMovements;

  List<WalletSummaryEntry> get chartEntries {
    final now = DateTime.now();
    if (period == WalletPeriod.day) {
      final byKey = {for (final e in _summaryDay) e.period: e};
      return List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        final key = _dateKey(d);
        return byKey[key] ?? WalletSummaryEntry(period: key);
      });
    }
    final byKey = {for (final e in _summaryMonth) e.period: e};
    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i), 1);
      final key = _monthKey(d);
      return byKey[key] ?? WalletSummaryEntry(period: key);
    });
  }

  Future<void> load() async {
    isLoading = !_loadedOnce;
    error = null;
    partialError = null;
    notifyListeners();

    final errors = <String>[];
    await Future.wait([
      _guard('saldo', _fetchWallet, errors),
      _guard('resumen', () => _fetchSummary(WalletPeriod.day), errors),
      if (_monthLoaded || period == WalletPeriod.month)
        _guard('resumen mensual', () => _fetchSummary(WalletPeriod.month),
            errors),
      _guard('movimientos', () => _fetchMovements(reset: true), errors),
    ]);

    _loadedOnce = true;
    if (errors.isNotEmpty && errors.length >= 3) {
      error = 'Error al cargar la cartera\n${errors.join('\n')}';
    } else if (errors.isNotEmpty) {
      partialError = 'No se pudo cargar: ${errors.join(' · ')}';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _guard(
      String name, Future<void> Function() fn, List<String> errors) async {
    try {
      await fn();
    } catch (e) {
      debugPrint('DriverWallet [$name] $e');
      errors.add('$name (${_describe(e)})');
    }
  }

  static String _describe(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      final data = e.response?.data;
      final msg = data is Map ? (data['error'] ?? data['message'] ?? '') : '';
      if (code == null) return 'sin conexión';
      return 'HTTP $code${msg.toString().isNotEmpty ? ': $msg' : ''}';
    }
    return e.runtimeType.toString();
  }

  Future<void> setPeriod(WalletPeriod p) async {
    if (period == p) return;
    period = p;
    notifyListeners();
    if (p == WalletPeriod.month && !_monthLoaded) {
      final errors = <String>[];
      await _guard(
          'resumen mensual', () => _fetchSummary(WalletPeriod.month), errors);
      if (errors.isNotEmpty) {
        partialError = 'No se pudo cargar: ${errors.join(' · ')}';
      }
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    notifyListeners();
    try {
      _page++;
      await _fetchMovements();
    } catch (_) {
      _page--;
    }
    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _fetchWallet() async {
    final res = await _api.getDriverWallet();
    wallet = DriverWallet.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> _fetchSummary(WalletPeriod p) async {
    final now = DateTime.now();
    final from = p == WalletPeriod.day
        ? _dateKey(now.subtract(const Duration(days: 6)))
        : _dateKey(DateTime(now.year, now.month - 5, 1));
    final to = _dateKey(now.add(const Duration(days: 1)));

    final res = await _api.getDriverWalletSummary(
      period: p == WalletPeriod.day ? 'day' : 'month',
      from: from,
      to: to,
    );
    final data = res.data;
    final list = data is Map
        ? (data['summary'] ?? data['data'] ?? []) as List? ?? []
        : data as List? ?? [];
    final entries = list
        .map((e) => WalletSummaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    if (p == WalletPeriod.day) {
      _summaryDay = entries;
    } else {
      _summaryMonth = entries;
      _monthLoaded = true;
    }
  }

  Future<void> _fetchMovements({bool reset = false}) async {
    if (reset) _page = 1;
    final res = await _api.getDriverWalletTransactions(
      page: _page,
      limit: _pageSize,
    );
    final data = res.data;
    List<dynamic> list;
    int total = 0;
    if (data is Map) {
      list = (data['transactions'] ?? data['movements'] ?? data['data'] ?? [])
              as List? ??
          [];
      total = (data['total'] as num?)?.toInt() ?? list.length;
    } else {
      list = data as List? ?? [];
      total = list.length;
    }
    final parsed = list
        .map((e) => WalletMovement.fromJson(e as Map<String, dynamic>))
        .toList();
    if (reset) {
      movements = parsed;
    } else {
      movements = [...movements, ...parsed];
    }
    totalMovements = total;
  }

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _monthKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
}
