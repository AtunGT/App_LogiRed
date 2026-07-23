import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';
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
    final driverId = (driver?.iduser != null && driver!.iduser != 0)
        ? driver.iduser
        : (_p.idDriver ?? 0);
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
                if (driverId != 0) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () => _showDriverReviews(context, driverId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Ver más reseñas',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                ],
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
                      label: 'Vehículo',
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
      return 'No hay información disponible sobre este conductor.';
    }

    // Resumen generado por IA en el backend (driver_info.summary_profile).
    if (driver.summaryProfile != null && driver.summaryProfile!.isNotEmpty) {
      return driver.summaryProfile!;
    }

    final parts = <String>[];

    if (driver.rating != null) {
      final r = driver.rating!;
      if (r >= 4.8) {
        parts.add(
            'Este conductor tiene valoraciones sobresalientes (${r.toStringAsFixed(1)} ★), lo que refleja un servicio excepcional y consistente.');
      } else if (r >= 4.5) {
        parts.add(
            'Este conductor cuenta con muy buenas valoraciones (${r.toStringAsFixed(1)} ★), indicando un servicio confiable y de calidad.');
      } else {
        parts.add(
            'Este conductor tiene valoraciones de ${r.toStringAsFixed(1)} ★.');
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
      return 'Conductor registrado en LogiRed. Revisa su vehículo y precio antes de aceptar.';
    }

    return parts.join(' ');
  }

  void _showDriverReviews(BuildContext context, int driverId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewsSheet(driverId: driverId),
    );
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
      await context.read<ApiService>().updateProposalStatus(
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
            Text('Sin foto del vehículo',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
}

class _ReviewsSheet extends StatefulWidget {
  final int driverId;
  const _ReviewsSheet({required this.driverId});

  @override
  State<_ReviewsSheet> createState() => _ReviewsSheetState();
}

class _ReviewsSheetState extends State<_ReviewsSheet> {
  bool _loading = true;
  String? _error;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res =
          await context.read<ApiService>().getDriverReviews(widget.driverId);
      final data = res.data;
      final list =
          (data is Map ? (data['reviews'] ?? data['data']) : data) as List? ??
              [];
      final reviews =
          list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
      // Primero las reseñas con comentario, luego por calificación descendente.
      reviews.sort((a, b) {
        if (a.hasComment != b.hasComment) return a.hasComment ? -1 : 1;
        return b.rating.compareTo(a.rating);
      });
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar las reseñas';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.reviews_outlined,
                        size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Reseñas',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (!_loading && _error == null && _reviews.isNotEmpty)
                      Text(
                        '${_reviews.length} en total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),
              Expanded(child: _buildBody(scrollController, colorScheme)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController controller, ColorScheme colorScheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: TextStyle(color: colorScheme.error)),
      );
    }
    if (_reviews.isEmpty) {
      return Center(
        child: Text(
          'Este conductor aún no tiene reseñas.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ReviewTile(review: _reviews[i]),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.person,
                    size: 18, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              _ReviewStars(rating: review.rating),
              const SizedBox(width: 6),
              Text(
                review.rating.toStringAsFixed(1),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (review.hasComment) ...[
            const SizedBox(height: 8),
            Text(
              review.review,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewStars extends StatelessWidget {
  final double rating;
  const _ReviewStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, size: 15, color: const Color(0xFFFFC107));
      }),
    );
  }
}
