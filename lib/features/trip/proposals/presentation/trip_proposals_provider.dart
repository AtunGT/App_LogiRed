import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';
import '../proposal_enrichment.dart';

class TripProposalsProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;

  TripProposalsProvider(this._api);

  List<Proposal> proposals = [];
  bool accepting = false;

  Future<void> loadProposals(int tripId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _api.getProposalsByRide(tripId);
      final data = response.data;
      final list = data is List
          ? data
          : (data['proposals'] ?? data['data'] ?? []) as List? ?? [];
      final basic = list
          .map((e) => Proposal.fromJson(e as Map<String, dynamic>))
          .toList();
      proposals = await Future.wait(basic.map(enrichProposal));
    } catch (e) {
      error = 'Error al cargar propuestas';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> acceptProposal(int proposalId, int tripId) async {
    accepting = true;
    error = null;
    notifyListeners();

    try {
      await _api.updateProposalStatus(
        proposalId,
        ProposalStatusRequest(idstatus: 1).toJson(),
      );
      await loadProposals(tripId);
    } catch (e) {
      error = 'Error al aceptar la propuesta';
    }

    accepting = false;
    notifyListeners();
  }
}
