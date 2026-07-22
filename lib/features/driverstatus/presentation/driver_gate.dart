import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/local/token_manager.dart';
import '../../../core/network/api_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../main/driver_main_screen.dart';
import 'driver_status_provider.dart';
import 'driver_status_screen.dart';

/// Puerta de entrada del conductor.
///
/// Sustituye a `DriverMainScreen` en la ruta `driverMain` para que los dos
/// puntos que navegan ahi (el arranque en `main.dart` y el login) no tengan
/// que duplicar la consulta de estado. Solo deja pasar al mapa si
/// `driver_status` es `approved`.
class DriverGate extends StatefulWidget {
  const DriverGate({super.key});

  @override
  State<DriverGate> createState() => _DriverGateState();
}

class _DriverGateState extends State<DriverGate> {
  late final DriverStatusProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = DriverStatusProvider(
      context.read<ApiService>(),
      context.read<TokenManager>(),
    );
    _provider.load();
    NotificationService.driverStatusRevision.addListener(_onPushedChange);
  }

  @override
  void dispose() {
    NotificationService.driverStatusRevision.removeListener(_onPushedChange);
    _provider.dispose();
    super.dispose();
  }

  /// Llego un push de administracion: el estado cambio, hay que releerlo.
  void _onPushedChange() {
    if (mounted) _provider.refresh();
  }

  Future<void> _logout() async {
    await _provider.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.roleSelection,
      (_) => false,
    );
  }

  Future<void> _openReapply() async {
    await Navigator.pushNamed(context, AppRoutes.driverReapply);
    // Al volver, el estado deberia ser `pending`; se confirma con la API en
    // vez de asumirlo.
    if (mounted) await _provider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<DriverStatusProvider>(
        builder: (context, provider, _) {
          if (provider.isResolving) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.canDrive) return const DriverMainScreen();

          return DriverStatusScreen(
            status: provider.driverStatus,
            reason: provider.rejectReason,
            onRefresh: provider.refresh,
            onReapply: _openReapply,
            onLogout: _logout,
          );
        },
      ),
    );
  }
}
