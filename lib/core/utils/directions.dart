import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/api_keys.dart';

const kMapsApiKey = googleMapsApiKey;

class NavStep {
  final String instruction;
  final String? maneuver;
  final LatLng end;
  const NavStep(
      {required this.instruction, required this.maneuver, required this.end});
}

class DirectionsRoute {
  /// Geometría detallada de la ruta (concatenación de las polilíneas por
  /// paso); la `overview_polyline` viene simplificada y se sale de las calles.
  final List<LatLng> points;
  final List<NavStep> steps;
  final double distanceMeters;
  final double durationSeconds;

  const DirectionsRoute({
    required this.points,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

Future<DirectionsRoute?> fetchDirectionsRoute(LatLng from, LatLng to) async {
  final res = await Dio().get(
    'https://maps.googleapis.com/maps/api/directions/json'
    '?origin=${from.latitude},${from.longitude}'
    '&destination=${to.latitude},${to.longitude}'
    '&mode=driving&language=es&key=$kMapsApiKey',
  );
  final routes = res.data['routes'] as List? ?? [];
  if (routes.isEmpty) return null;
  final legs = routes[0]['legs'] as List? ?? [];
  if (legs.isEmpty) return null;
  final leg = legs[0] as Map;

  final points = <LatLng>[];
  final steps = <NavStep>[];
  for (final s in (leg['steps'] as List? ?? [])) {
    final encoded = s['polyline']?['points'] as String?;
    if (encoded != null) {
      final pts = decodePolyline(encoded);
      final skipJoint =
          points.isNotEmpty && pts.isNotEmpty && pts.first == points.last;
      points.addAll(skipJoint ? pts.skip(1) : pts);
    }
    final end = s['end_location'] as Map?;
    steps.add(NavStep(
      instruction: stripHtml((s['html_instructions'] as String?) ?? ''),
      maneuver: s['maneuver'] as String?,
      end: LatLng((end?['lat'] as num?)?.toDouble() ?? 0,
          (end?['lng'] as num?)?.toDouble() ?? 0),
    ));
  }
  if (points.length < 2) {
    final encoded = routes[0]['overview_polyline']?['points'] as String?;
    if (encoded == null) return null;
    points
      ..clear()
      ..addAll(decodePolyline(encoded));
  }

  return DirectionsRoute(
    points: points,
    steps: steps,
    distanceMeters: (leg['distance']?['value'] as num?)?.toDouble() ?? 0,
    durationSeconds: (leg['duration']?['value'] as num?)?.toDouble() ?? 0,
  );
}

List<LatLng> decodePolyline(String encoded) {
  final List<LatLng> points = [];
  int index = 0, lat = 0, lng = 0;
  while (index < encoded.length) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dLat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    lat += dLat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dLng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    lng += dLng;
    points.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return points;
}

String stripHtml(String s) => s
    .replaceAll(RegExp(r'<[^>]*>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String formatMeters(double m) => m >= 1000
    ? '${(m / 1000).toStringAsFixed(1)} km'
    : '${(m / 10).round() * 10} m';

String formatDuration(double seconds) {
  final mins = (seconds / 60).ceil();
  if (mins >= 60) {
    final rem = mins % 60;
    return rem > 0 ? '${mins ~/ 60} h $rem min' : '${mins ~/ 60} h';
  }
  return '${mins < 1 ? 1 : mins} min';
}
