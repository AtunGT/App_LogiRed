import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';

class DriverTripDetailProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;

  DriverTripDetailProvider(this._api);

  Trip? trip;
  String clientName = 'Cliente';
  String clientInitial = 'C';
  String? clientImageUrl;
  String suggestedPrice = '—';
  String price = '';
  String comment = '';
  bool isSending = false;
  bool proposalSent = false;

  void onPriceChange(String v) {
    price = v;
    notifyListeners();
  }

  void onCommentChange(String v) {
    comment = v;
    notifyListeners();
  }

  Future<void> load(int tripId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final tripRes = await _api.getRideById(tripId);
      final raw = tripRes.data['ride'] ?? tripRes.data;
      trip = Trip.fromJson(raw as Map<String, dynamic>);

      final sp = raw['suggested_price'] ?? raw['price_suggestion'];
      if (sp != null) {
        final spVal = (sp as num).toDouble();
        if (spVal > 0) {
          suggestedPrice = '\$${spVal.toInt().toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
              )}';
        }
      }

      try {
        final clientId =
            raw['id_client'] ?? raw['client_id'] ?? raw['idclient'];
        if (clientId != null && clientId != 0) {
          final clientRes = await _api.getUserProfile(clientId as int);
          final user = UserResponse.fromJson(clientRes.data);
          clientName = '${user.name} ${user.lastname}'.trim();
          if (clientName.trim().isEmpty) clientName = 'Cliente';
          clientInitial =
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'C';
          clientImageUrl = user.imageUrl;
        }
      } catch (_) {}
    } catch (e) {
      error = 'Error al cargar la información';
      debugPrint('Error cargando viaje: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> sendProposal() async {
    if (price.isEmpty) {
      error = 'Ingresa un precio para tu propuesta';
      notifyListeners();
      return;
    }
    final parsed = double.tryParse(price.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) {
      error = 'Ingresa un precio válido';
      notifyListeners();
      return;
    }

    isSending = true;
    error = null;
    notifyListeners();

    try {
      await _api.sendProposal({
        'id_ride': trip!.id,
        'price': parsed,
        if (comment.trim().isNotEmpty) 'comment': comment.trim(),
      });
      proposalSent = true;
    } catch (_) {
      error = 'Error al enviar la propuesta. Intenta de nuevo';
    }

    isSending = false;
    notifyListeners();
  }
}
