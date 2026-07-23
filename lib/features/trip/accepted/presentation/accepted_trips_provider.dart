import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/utils/ride_status.dart';

enum ProposalFilter { pending, accepted, inProgress, notSelected }

const int kProposalAccepted = 1;
const int kProposalRejected = 3;

bool _rideInProgress(DriverProposalItem p) =>
    RideStatus.isInCourse(p.rideStatus);

bool _rideClosed(DriverProposalItem p) =>
    p.rideLoaded && RideStatus.isClosed(p.rideStatus);

bool _rideTakenByOther(DriverProposalItem p) =>
    p.status != kProposalAccepted &&
    p.rideLoaded &&
    p.rideStatus != 0 &&
    p.rideStatus != RideStatus.pending;

bool _isNotSelected(DriverProposalItem p) =>
    p.status == kProposalRejected || _rideTakenByOther(p);

class AcceptedTripsProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;

  List<DriverProposalItem> _all = [];
  ProposalFilter filter = ProposalFilter.pending;
  Timer? _refreshTimer;

  AcceptedTripsProvider(this._api) {
    _refreshTimer = Timer.periodic(
        const Duration(seconds: 20), (_) => loadTrips(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  bool _isPending(DriverProposalItem p) =>
      p.status != kProposalAccepted && !_isNotSelected(p);

  bool _isAccepted(DriverProposalItem p) =>
      p.status == kProposalAccepted &&
      p.rideLoaded &&
      !_rideClosed(p) &&
      !_rideInProgress(p);

  bool _isInProgress(DriverProposalItem p) =>
      p.status == kProposalAccepted && p.rideLoaded && _rideInProgress(p);

  List<DriverProposalItem> get proposals {
    switch (filter) {
      case ProposalFilter.pending:
        return _all.where(_isPending).toList();
      case ProposalFilter.accepted:
        return _all.where(_isAccepted).toList();
      case ProposalFilter.inProgress:
        return _all.where(_isInProgress).toList();
      case ProposalFilter.notSelected:
        return _all.where(_isNotSelected).toList();
    }
  }

  int get countPending => _all.where(_isPending).length;
  int get countAccepted => _all.where(_isAccepted).length;
  int get countInProgress => _all.where(_isInProgress).length;
  int get countNotSelected => _all.where(_isNotSelected).length;

  void setFilter(ProposalFilter f) {
    filter = f;
    notifyListeners();
  }

  Future<void> loadTrips({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      error = null;
      notifyListeners();
    }

    try {
      final res = await _api.getMyProposals();
      final list = (res.data['proposals'] ?? res.data) as List? ?? [];
      final assignedRides = await _loadAssignedRides();
      _all = await Future.wait(list.map(
          (e) => _toProposalItem(e as Map<String, dynamic>, assignedRides)));
      error = null;
    } catch (e) {
      debugPrint('[proposals] GET proposals/driver falló: $e');
      if (!silent) error = 'Error al cargar las propuestas';
    }

    if (!silent) isLoading = false;
    notifyListeners();
  }

  Future<Map<int, Trip>> _loadAssignedRides() async {
    try {
      final res = await _api.getMyAcceptedTrips();
      final list = res.data['rides'] as List? ?? [];
      return {
        for (final t
            in list.map((e) => Trip.fromJson(e as Map<String, dynamic>)))
          t.id: t,
      };
    } catch (e) {
      debugPrint('[proposals] GET rides/driver/me falló: $e');
      return {};
    }
  }

  Future<DriverProposalItem> _toProposalItem(
      Map<String, dynamic> p, Map<int, Trip> assignedRides) async {
    final idRide = p['id_ride'] ?? p['idride'] ?? 0;

    Trip? trip = assignedRides[idRide];
    if (trip == null && idRide != 0) {
      try {
        final r = await _api.getRideById(idRide);
        final rd = (r.data['ride'] ?? r.data) as Map<String, dynamic>;
        trip = Trip.fromJson(rd);
      } catch (e) {
        debugPrint('[proposals] GET rides/$idRide falló: $e');
      }
    }

    String clientName = 'Cliente';
    final clientId = trip?.clientId ?? 0;
    if (clientId != 0) {
      try {
        final c = await _api.getUserProfile(clientId);
        final cd = (c.data['data'] ?? c.data) as Map<String, dynamic>;
        final n = '${cd['name'] ?? ''} ${cd['lastname'] ?? ''}'.trim();
        if (n.isNotEmpty) clientName = n;
      } catch (e) {
        debugPrint('[proposals] GET users/$clientId falló: $e');
      }
    }

    return DriverProposalItem(
      id: p['id'] ?? p['idproposal'] ?? 0,
      price: (p['price'] as num?)?.toDouble() ?? 0.0,
      idRide: idRide,
      status: p['idstatus'] ?? p['idproposalstatus'] ?? p['status'] ?? 0,
      comment: p['comment'],
      origin: trip?.origin ?? '',
      destination: trip?.destination ?? '',
      date: trip?.date ?? '',
      hour: trip?.hour ?? '',
      approxWeight: trip?.approxWeight ?? 0,
      description: trip?.description,
      clientName: clientName,
      paymentMethod: trip?.paymentMethod,
      rideStatus: trip?.status ?? 0,
      rideLoaded: trip != null,
    );
  }
}
