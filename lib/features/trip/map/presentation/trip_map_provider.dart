import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';

class TripMapScreen extends StatefulWidget {
  final int tripId;
  const TripMapScreen({super.key, required this.tripId});

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  Trip? trip;
  bool isLoading = true;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Mantiene la pantalla encendida mientras se ve el mapa del viaje.
    WakelockPlus.enable();
    _loadTrip();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadTrip() async {
    try {
      final response = await context.read<ApiService>().getRideById(widget.tripId);
      final data = response.data['ride'] ?? response.data;
      if (mounted) {
        setState(() {
          trip = Trip.fromJson(data);
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa del viaje')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trip == null
              ? const Center(child: Text('Error al cargar el mapa'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(trip!.originLat, trip!.originLng),
                    zoom: 12,
                  ),
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  markers: {
                    Marker(
                      markerId: const MarkerId('origin'),
                      position: LatLng(trip!.originLat, trip!.originLng),
                      infoWindow:
                          InfoWindow(title: 'Origen', snippet: trip!.origin),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                    ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position:
                          LatLng(trip!.destinationLat, trip!.destinationLng),
                      infoWindow: InfoWindow(
                          title: 'Destino', snippet: trip!.destination),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: [
                        LatLng(trip!.originLat, trip!.originLng),
                        LatLng(trip!.destinationLat, trip!.destinationLng),
                      ],
                      color: Colors.blue,
                      width: 4,
                    ),
                  },
                ),
    );
  }
}
