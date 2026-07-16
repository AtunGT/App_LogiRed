import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

enum _SecurityThreat { none, mockGps, vpn }

class MockLocationGuard extends StatefulWidget {
  final Widget child;
  const MockLocationGuard({super.key, required this.child});

  @override
  State<MockLocationGuard> createState() => _MockLocationGuardState();
}

class _MockLocationGuardState extends State<MockLocationGuard> {
  _SecurityThreat _threat = _SecurityThreat.none;
  StreamSubscription<Position>? _gpsSub;
  Timer? _vpnTimer;

  @override
  void initState() {
    super.initState();
    _startGpsMonitoring();
    _startVpnMonitoring();
  }

  Future<void> _startGpsMonitoring() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((position) {
      if (!mounted) return;
      final threat =
          position.isMocked ? _SecurityThreat.mockGps : _SecurityThreat.none;
      if (_threat == _SecurityThreat.none ||
          _threat == _SecurityThreat.mockGps) {
        if (_threat != threat) setState(() => _threat = threat);
      }
    });
  }

  Future<void> _startVpnMonitoring() async {
    await _checkVpn();
    _vpnTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkVpn());
  }

  Future<void> _checkVpn() async {
    if (!mounted) return;
    try {
      final vpnActive = await _isVpnActive();
      if (!mounted) return;
      if (vpnActive && _threat != _SecurityThreat.vpn) {
        setState(() => _threat = _SecurityThreat.vpn);
      } else if (!vpnActive && _threat == _SecurityThreat.vpn) {
        setState(() => _threat = _SecurityThreat.none);
      }
    } catch (_) {}
  }

  static Future<bool> _isVpnActive() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.any,
    );
    return interfaces.any((iface) {
      final name = iface.name.toLowerCase();
      return name.startsWith('tun') ||
          name.startsWith('ppp') ||
          name.startsWith('wg') ||
          name.startsWith('ipsec') ||
          name.startsWith('tap') ||
          name.contains('vpn');
    });
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _vpnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_threat != _SecurityThreat.none)
          Positioned.fill(child: _SecurityBlockerOverlay(threat: _threat)),
      ],
    );
  }
}

class _SecurityBlockerOverlay extends StatelessWidget {
  final _SecurityThreat threat;
  const _SecurityBlockerOverlay({required this.threat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isVpn = threat == _SecurityThreat.vpn;

    return PopScope(
      canPop: false,
      child: Material(
        color: colorScheme.surface,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVpn ? Icons.vpn_lock : Icons.gps_off,
                      size: 56,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    isVpn ? 'VPN detectada' : 'GPS falso detectado',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isVpn
                        ? 'Detectamos que tienes una VPN activa. '
                            'Desactívala para poder continuar usando LogiRed.'
                        : 'Detectamos que estás usando una aplicación de GPS falso. '
                            'Desactívala para poder continuar usando LogiRed.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
