import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/model/models.dart';
import 'car_provider.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final _pageCtrl = PageController();
  int _imgIndex = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => CarProvider()..loadCars(),
      child: Consumer<CarProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LogiRed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    if (provider.isLoading)
                      const Expanded(
                          child: Center(child: CircularProgressIndicator()))
                    else if (provider.cars.isEmpty)
                      Expanded(child: _EmptyState(colorScheme: colorScheme))
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          child: _CarCard(
                            car: provider.cars.first,
                            colorScheme: colorScheme,
                            pageCtrl: _pageCtrl,
                            imgIndex: _imgIndex,
                            onPageChanged: (i) => setState(() => _imgIndex = i),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final Car car;
  final ColorScheme colorScheme;
  final PageController pageCtrl;
  final int imgIndex;
  final void Function(int) onPageChanged;

  const _CarCard({
    required this.car,
    required this.colorScheme,
    required this.pageCtrl,
    required this.imgIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final images = [
      car.frontViewImage,
      car.backViewImage,
      car.platesImage,
      car.spacesImage,
    ].whereType<String>().where((s) => s.isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                ),
                Text(
                  'MI VEHÍCULO',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          if (images.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: pageCtrl,
                    onPageChanged: onPageChanged,
                    itemCount: images.length,
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => _ImgPlaceholder(colorScheme),
                      errorWidget: (_, __, ___) => _ImgPlaceholder(colorScheme),
                    ),
                  ),
                ),
              ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == imgIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _ImgPlaceholder(colorScheme, height: 160),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.brand} ${car.model}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text('Color: ${car.color}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onSurface)),
                Text('Placas: ${car.carRegistration}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onSurface)),
                Text('Capacidad de carga:',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onSurface)),
                Text('${car.maxCapacity} KG',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onSurface)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Solicitar un cambio de vehículo',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  final double height;
  const _ImgPlaceholder(this.colorScheme, {this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.directions_car_outlined,
            size: 48, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  const _EmptyState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 56, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Sin vehículo registrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Contacta a soporte para registrar tu vehículo',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
