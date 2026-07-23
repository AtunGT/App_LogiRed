import 'package:flutter/foundation.dart';

enum ViewStatus { initial, loading, success, error }

mixin ViewStateMixin on ChangeNotifier {
  ViewStatus _status = ViewStatus.initial;
  String? _error;

  ViewStatus get status => _status;
  bool get isInitial => _status == ViewStatus.initial;
  bool get isSuccess => _status == ViewStatus.success;
  bool get hasError => _status == ViewStatus.error;

  bool get isLoading => _status == ViewStatus.loading;
  set isLoading(bool value) {
    if (value) {
      _status = ViewStatus.loading;
    } else if (_status == ViewStatus.loading) {
      _status = _error == null ? ViewStatus.success : ViewStatus.error;
    }
  }

  String? get error => _error;
  set error(String? value) {
    _error = value;
    if (_status == ViewStatus.loading) return;
    if (value != null) {
      _status = ViewStatus.error;
    } else if (_status == ViewStatus.error) {
      _status = ViewStatus.success;
    }
  }
}
