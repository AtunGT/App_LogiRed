import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map_picker_screen.dart';
import 'request_trip_provider.dart';
import '../../../../core/config/api_keys.dart';

const _apiKey = googleMapsApiKey;

class RequestTripScreen extends StatefulWidget {
  final bool isActive;
  const RequestTripScreen({this.isActive = false, super.key});

  @override
  State<RequestTripScreen> createState() => _RequestTripScreenState();
}

class _RequestTripScreenState extends State<RequestTripScreen> {
  final _originCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _hourCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  static const _prefKey = 'publish_hint_dismissed';

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowHint());
    }
  }

  @override
  void didUpdateWidget(RequestTripScreen old) {
    super.didUpdateWidget(old);
    if (!old.isActive && widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowHint());
    }
  }

  Future<void> _maybeShowHint() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) == true) return;
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PublishHintDialog(
        onDismiss: (dontShowAgain) async {
          if (dontShowAgain) {
            await prefs.setBool(_prefKey, true);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destinationCtrl.dispose();
    _dateCtrl.dispose();
    _hourCtrl.dispose();
    _weightCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(RequestTripProvider provider) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      final formatted = '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
      final display = '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
      _dateCtrl.text = display;
      provider.onDateChange(formatted);
    }
  }

  Future<void> _pickTime(RequestTripProvider provider) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) {
      final displayHour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      _hourCtrl.text =
          '${displayHour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
      provider.onHourChange(
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _pickDestinationOnMap(RequestTripProvider provider) async {
    final initial = provider.destinationLat != 0
        ? LatLng(provider.destinationLat, provider.destinationLng)
        : provider.originLat != 0
            ? LatLng(provider.originLat, provider.originLng)
            : null;
    final result = await Navigator.of(context).push<PickedPlace>(
      MaterialPageRoute(builder: (_) => MapPickerScreen(initial: initial)),
    );
    if (result == null || !mounted) return;
    provider.setDestinationFromPlace(result.address, result.lat, result.lng);
    _destinationCtrl.text = result.address;
  }

  void _clearFields() {
    _originCtrl.clear();
    _destinationCtrl.clear();
    _dateCtrl.clear();
    _hourCtrl.clear();
    _weightCtrl.clear();
    _descCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => RequestTripProvider(),
      child: Consumer<RequestTripProvider>(
        builder: (context, provider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      '¡Viaje publicado! Los conductores recibirán la notificación.'),
                  backgroundColor: colorScheme.primary,
                ),
              );
              _clearFields();
              provider.success = false;
            }
          });

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publicar un Viaje',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 20),
                    _SectionHeader(
                      icon: Icons.location_on_outlined,
                      label: 'Ruta del Viaje',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      colorScheme: colorScheme,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _placesField(
                                  label: 'Lugar de Origen',
                                  required: true,
                                  controller: _originCtrl,
                                  colorScheme: colorScheme,
                                  onSelected: (p) {
                                    final addr = p.description ?? '';
                                    final lat =
                                        double.tryParse(p.lat ?? '0') ?? 0;
                                    final lng =
                                        double.tryParse(p.lng ?? '0') ?? 0;
                                    provider.setOriginFromPlace(addr, lat, lng);
                                    _originCtrl.text = addr;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: provider.isLocating
                                    ? const SizedBox(
                                        width: 46,
                                        height: 46,
                                        child: Center(
                                            child: SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2))),
                                      )
                                    : IconButton.filled(
                                        icon: const Icon(Icons.my_location,
                                            size: 20),
                                        tooltip: 'Usar mi ubicación',
                                        onPressed: () => provider
                                            .getCurrentLocation(_originCtrl),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _placesField(
                            label: 'Lugar de Destino',
                            required: true,
                            controller: _destinationCtrl,
                            colorScheme: colorScheme,
                            onSelected: (p) {
                              final addr = p.description ?? '';
                              final lat = double.tryParse(p.lat ?? '0') ?? 0;
                              final lng = double.tryParse(p.lng ?? '0') ?? 0;
                              provider.setDestinationFromPlace(addr, lat, lng);
                              _destinationCtrl.text = addr;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => _pickDestinationOnMap(provider),
                              icon: const Icon(Icons.map_outlined, size: 18),
                              label: const Text('Seleccionar en el mapa'),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha y Hora',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      colorScheme: colorScheme,
                      child: Column(
                        children: [
                          _readOnlyField(
                            label: 'Fecha del Servicio',
                            required: true,
                            controller: _dateCtrl,
                            suffixIcon: Icons.calendar_today_outlined,
                            colorScheme: colorScheme,
                            onTap: () => _pickDate(provider),
                          ),
                          const SizedBox(height: 12),
                          _readOnlyField(
                            label: 'Hora de Inicio',
                            required: true,
                            controller: _hourCtrl,
                            suffixIcon: Icons.access_time_outlined,
                            colorScheme: colorScheme,
                            onTap: () => _pickTime(provider),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      icon: Icons.inventory_2_outlined,
                      label: 'Detalles de la Carga',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      colorScheme: colorScheme,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Peso Aproximado (kg)', colorScheme),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _weightCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: provider.onWeightChange,
                            decoration: _inputDeco(
                              colorScheme: colorScheme,
                              hintText: '800',
                              prefixText: 'Ej: ',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _fieldLabel('Descripción Detallada', colorScheme),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descCtrl,
                            maxLines: 4,
                            onChanged: provider.onDescriptionChange,
                            decoration: _inputDeco(
                              colorScheme: colorScheme,
                              hintText:
                                  'Describe tu carga: cantidad de artículos, '
                                  'dimensiones especiales, fragilidad, '
                                  'necesidades de manejo, acceso al inmueble, etc.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Método de Pago',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      colorScheme: colorScheme,
                      child: _PaymentMethodSelector(
                        selected: provider.paymentMethod,
                        onChanged: provider.onPaymentMethodChange,
                        colorScheme: colorScheme,
                      ),
                    ),
                    if (provider.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          provider.error!,
                          style: TextStyle(color: colorScheme.onErrorContainer),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : provider.submit,
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.arrow_forward),
                        label: const Text(
                          'Publicar Viaje',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
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

  Widget _placesField({
    required String label,
    required bool required,
    required TextEditingController controller,
    required ColorScheme colorScheme,
    required void Function(Prediction) onSelected,
  }) {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: controller,
      googleAPIKey: _apiKey,
      countries: const ['mx'],
      inputDecoration: _inputDeco(
        colorScheme: colorScheme,
        labelText: required ? '$label *' : label,
        prefixIcon: const Icon(Icons.location_on_outlined),
      ),
      debounceTime: 400,
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: onSelected,
      itemClick: (prediction) {
        controller.text = prediction.description ?? '';
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
        FocusScope.of(context).unfocus();
      },
    );
  }

  Widget _readOnlyField({
    required String label,
    required bool required,
    required TextEditingController controller,
    required IconData suffixIcon,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: _inputDeco(
        colorScheme: colorScheme,
        labelText: required ? '$label *' : label,
        suffixIcon: Icon(suffixIcon, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  InputDecoration _inputDeco({
    required ColorScheme colorScheme,
    String? labelText,
    String? hintText,
    String? prefixText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _fieldLabel(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final ColorScheme colorScheme;

  const _SectionCard({required this.child, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final ColorScheme colorScheme;

  const _PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PaymentOption(
            label: 'Efectivo',
            icon: Icons.payments_outlined,
            selected: selected != 2,
            onTap: () => onChanged(1),
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PaymentOption(
            label: 'Tarjeta',
            icon: Icons.credit_card_rounded,
            selected: selected == 2,
            onTap: () => onChanged(2),
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishHintDialog extends StatefulWidget {
  final Future<void> Function(bool dontShowAgain) onDismiss;
  const _PublishHintDialog({required this.onDismiss});

  @override
  State<_PublishHintDialog> createState() => _PublishHintDialogState();
}

class _PublishHintDialogState extends State<_PublishHintDialog> {
  bool _dontShow = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'DETALLES DEL SERVICIO',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Proporciona la mayor cantidad de información posible para recibir propuestas más precisas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _dontShow = !_dontShow),
            child: Row(
              children: [
                Icon(
                  _dontShow
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_off_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No volver a mostrar este mensaje',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: _dontShow,
                  onChanged: (v) => setState(() => _dontShow = v),
                  activeThumbColor: colorScheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await widget.onDismiss(_dontShow);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Aceptar',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
