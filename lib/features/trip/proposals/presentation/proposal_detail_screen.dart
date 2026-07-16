import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/model/models.dart';
import '../proposal_enrichment.dart';

class ProposalDetailScreen extends StatefulWidget {
  final Proposal proposal;
  final int tripId;
  final VoidCallback onAccepted;
  final bool readOnly;

  const ProposalDetailScreen({
    super.key,
    required this.proposal,
    required this.tripId,
    required this.onAccepted,
    this.readOnly = false,
  });

  @override
  State<ProposalDetailScreen> createState() => _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends State<ProposalDetailScreen> {
  late Proposal _p = widget.proposal;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (_p.driver == null || _p.car == null) {
      _loading = true;
      _enrich();
    }
  }

  Future<void> _enrich() async {
    final full = await enrichProposal(_p);
    if (mounted) {
      setState(() {
        _p = full;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final driver = _p.driver;
    final car = _p.car;
    final driverName = (driver != null &&
            '${driver.name} ${driver.lastname}'.trim().isNotEmpty)
        ? '${driver.name} ${driver.lastname}'.trim()
        : 'Conductor';
    final initial = driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C';

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.readOnly ? 'Conductor asignado' : 'Detalles de la propuesta',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (car?.frontViewImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: car!.frontViewImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    _CarPlaceholder(colorScheme: colorScheme),
              ),
            )
          else
            _CarPlaceholder(colorScheme: colorScheme),
          const SizedBox(height: 16),
          _Card(
            colorScheme: colorScheme,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage:
                      (driver?.imageUrl != null && driver!.imageUrl!.isNotEmpty)
                          ? CachedNetworkImageProvider(driver.imageUrl!)
                              as ImageProvider
                          : null,
                  child: (driver?.imageUrl == null || driver!.imageUrl!.isEmpty)
                      ? Text(
                          initial,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      if (driver?.rating != null) ...[
                        const Icon(Icons.star_rounded,
                            size: 16, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        Text(
                          driver!.rating!.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (driver?.totalTrips != null)
                        Text(
                          '${driver!.totalTrips} viajes',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 14, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Resumen de IA',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _buildAiSummary(driver),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (car != null)
            _Card(
              colorScheme: colorScheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                      icon: Icons.directions_car_outlined,
                      label: 'VehÃ­culo',
                      colorScheme: colorScheme),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Modelo', value: '${car.brand} ${car.model}'),
                  _InfoRow(label: 'Color', value: car.color),
                  _InfoRow(label: 'Placas', value: car.carRegistration),
                  _InfoRow(
                      label: 'Capacidad de carga',
                      value: '${car.maxCapacity} KG',
                      isLast: true),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _Card(
            colorScheme: colorScheme,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(
                    icon: Icons.attach_money,
                    label: 'Precio del viaje',
                    colorScheme: colorScheme),
                Text(
                  '\$${_p.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          if (_p.comment != null && _p.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Card(
              colorScheme: colorScheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                      icon: Icons.comment_outlined,
                      label: 'Comentario del viaje',
                      colorScheme: colorScheme),
                  const SizedBox(height: 10),
                  Text(
                    '"${_p.comment!}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ],
          if (_p.estimatedTime != null) ...[
            const SizedBox(height: 12),
            _Card(
              colorScheme: colorScheme,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle(
                      icon: Icons.schedule_outlined,
                      label: 'Tiempo estimado',
                      colorScheme: colorScheme),
                  Text(
                    _p.estimatedTime!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: widget.readOnly
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _AcceptButton(
                  proposal: _p,
                  onAccepted: () {
                    widget.onAccepted();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
    );
  }

  String _buildAiSummary(UserResponse? driverArg) {
    final driver = driverArg;
    if (driver == null) {
      return 'No hay informaciÃ³n disponible sobre este conductor.';
    }

    final parts = <String>[];

    if (driver.rating != null) {
      final r = driver.rating!;
      if (r >= 4.8) {
        parts.add(
            'Este conductor tiene valoraciones sobresalientes (${r.toStringAsFixed(1)} â˜…), lo que refleja un servicio excepcional y consistente.');
      } else if (r >= 4.5) {
        parts.add(
            'Este conductor cuenta con muy buenas valoraciones (${r.toStringAsFixed(1)} â˜…), indicando un servicio confiable y de calidad.');
      } else {
        parts.add(
            'Este conductor tiene valoraciones de ${r.toStringAsFixed(1)} â˜….');
      }
    }

    if (driver.totalTrips != null && driver.totalTrips! > 0) {
      final t = driver.totalTrips!;
      if (t >= 100) {
        parts.add(
            'Con $t viajes completados, es un conductor experimentado que conoce bien el proceso de mudanzas y transporte.');
      } else if (t >= 20) {
        parts.add('Cuenta con $t viajes completados exitosamente.');
      } else {
        parts.add('Ha completado $t viajes en la plataforma.');
      }
    }

    if (parts.isEmpty) {
      return 'Conductor registrado en LogiRed. Revisa su vehÃ­culo y precio antes de aceptar.';
    }

    return parts.join(' ');
  }
}

class _AcceptButton extends StatefulWidget {
  final Proposal proposal;
  final VoidCallback onAccepted;
  const _AcceptButton({required this.proposal, required this.onAccepted});

  @override
  State<_AcceptButton> createState() => _AcceptButtonState();
}

class _AcceptButtonState extends State<_AcceptButton> {
  bool _loading = false;

  Future<void> _accept() async {
    setState(() => _loading = true);
    try {
      await sl.apiService.updateProposalStatus(
        widget.proposal.id,
        ProposalStatusRequest(idstatus: 1).toJson(),
      );
      widget.onAccepted();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al aceptar la propuesta')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _accept,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.check_circle_outline),
        label: const Text('Aceptar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final ColorScheme colorScheme;
  const _Card({required this.child, required this.colorScheme});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  const _SectionTitle(
      {required this.icon, required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      )),
              Text(value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: colorScheme.outlineVariant),
      ],
    );
  }
}

class _CarPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  const _CarPlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 56,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text('Sin foto del vehÃ­culo',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
}
