import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class PickedPlace {
  final String address;
  final double lat;
  final double lng;
  const PickedPlace(this.address, this.lat, this.lng);
}

class MapPickerScreen extends StatefulWidget {
  final LatLng? initial;
  final String title;
  const MapPickerScreen({
    super.key,
    this.initial,
    this.title = 'Selecciona el destino',
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _fallback = LatLng(16.7516, -93.1161);

  GoogleMapController? _mapCtrl;
  late LatLng _center = widget.initial ?? _fallback;
  String? _address;
  bool _resolving = false;
  bool _locating = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve(_center));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapCtrl?.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition pos) => _center = pos.target;

  void _onCameraIdle() {
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 300), () => _resolve(_center));
  }

  Future<void> _resolve(LatLng pos) async {
    setState(() => _resolving = true);
    String? address;
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _address = (address == null || address.isEmpty) ? null : address;
      _resolving = false;
    });
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      final status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) return;
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final target = LatLng(pos.latitude, pos.longitude);
      await _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _confirm() {
    Navigator.of(context).pop(
      PickedPlace(
        _address ??
            '${_center.latitude.toStringAsFixed(5)}, '
                '${_center.longitude.toStringAsFixed(5)}',
        _center.latitude,
        _center.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            onMapCreated: (c) => _mapCtrl = c,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 44),
              child: Icon(Icons.location_on, size: 46, color: cs.error),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 190,
            child: FloatingActionButton.small(
              heroTag: 'pickerMyLocation',
              backgroundColor: cs.surfaceContainerLowest,
              foregroundColor: cs.primary,
              onPressed: _locating ? null : _goToMyLocation,
              child: _locating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _AddressCard(
              address: _address,
              resolving: _resolving,
              onConfirm: _confirm,
              colorScheme: cs,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String? address;
  final bool resolving;
  final VoidCallback onConfirm;
  final ColorScheme colorScheme;

  const _AddressCard({
    required this.address,
    required this.resolving,
    required this.onConfirm,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Material(
      color: cs.surfaceContainerLowest,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Punto seleccionado',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: resolving
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: cs.primary),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Obteniendo dirección…',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                        ],
                      )
                    : Text(
                        address ?? 'Mueve el mapa para elegir el destino',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                      ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Confirmar destino',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
