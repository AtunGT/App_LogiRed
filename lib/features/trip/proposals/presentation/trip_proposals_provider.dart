import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/model/models.dart';
import '../proposal_enrichment.dart';

class TripProposalsProvider extends ChangeNotifier {
  List<Proposal> proposals = [];
  bool isLoading = false;
  String? error;
  bool accepting = false;

  Future<void> loadProposals(int tripId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await sl.apiService.getProposalsByRide(tripId);
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
      await sl.apiService.updateProposalStatus(
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
