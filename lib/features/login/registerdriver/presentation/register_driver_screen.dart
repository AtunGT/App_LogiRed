import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../domain/repository/register_driver_repository.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/responsive.dart';
import 'register_driver_provider.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _birthdateCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _birthdateCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _plateCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (c) => RegisterDriverProvider(c.read<RegisterDriverRepository>()),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: SafeArea(
          child: Consumer<RegisterDriverProvider>(
            builder: (context, provider, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (provider.registerSuccess) {
                  Navigator.pushReplacementNamed(context, '/verify-email',
                      arguments: provider.registeredEmail);
                }
              });

              final hPad = Responsive.horizontalPadding(context);
              final maxW = Responsive.maxContentWidth(context);

              Widget scrollable = SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/logo.png', height: 36),
                          const SizedBox(width: 10),
                          Text(
                            'LogiRed',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Crear Cuenta',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _stepSubtitle(provider.currentStep),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StepTabs(currentStep: provider.currentStep),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: _buildStepContent(
                                  context, provider, colorScheme),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );

              if (maxW != double.infinity) {
                scrollable = Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: scrollable,
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(child: scrollable),
                  _buildBottomButtons(context, provider, colorScheme),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context,
      RegisterDriverProvider provider, ColorScheme colorScheme) {
    switch (provider.currentStep) {
      case 0:
        return _buildStep1(context, provider, colorScheme);
      case 1:
        return _buildStep2(context, provider, colorScheme);
      case 2:
        return _buildStep3(context, provider, colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1(BuildContext context, RegisterDriverProvider provider,
      ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDriverPhotoField(context, provider, colorScheme),
        if (provider.fieldErrors['photo'] != null) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              provider.fieldErrors['photo']!,
              style: TextStyle(color: colorScheme.error, fontSize: 11),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _label(context, 'Nombre(s)', colorScheme,
            hasError: provider.fieldErrors['name'] != null),
        const SizedBox(height: 8),
        _field(
          controller: _nameCtrl,
          hint: 'Tu nombre',
          icon: Icons.person_outline,
          colorScheme: colorScheme,
          onChanged: provider.onFirstNameChange,
          errorText: provider.fieldErrors['name'],
          maxLength: 50,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ,]')),
          ],
        ),
        const SizedBox(height: 16),
        _label(context, 'Apellido(s)', colorScheme,
            hasError: provider.fieldErrors['lastname'] != null),
        const SizedBox(height: 8),
        _field(
          controller: _lastNameCtrl,
          hint: 'Tu apellido',
          icon: Icons.person_outline,
          colorScheme: colorScheme,
          onChanged: provider.onLastNameChange,
          errorText: provider.fieldErrors['lastname'],
          maxLength: 40,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ,]')),
          ],
        ),
        const SizedBox(height: 16),
        _label(context, 'Correo electrónico', colorScheme,
            hasError: provider.fieldErrors['email'] != null),
        const SizedBox(height: 8),
        _field(
          controller: _emailCtrl,
          hint: 'tu@correo.com',
          icon: Icons.mail_outline,
          colorScheme: colorScheme,
          type: TextInputType.emailAddress,
          onChanged: provider.onEmailChange,
          errorText: provider.fieldErrors['email'],
        ),
        const SizedBox(height: 16),
        _label(context, 'Teléfono', colorScheme,
            hasError: provider.fieldErrors['phone'] != null),
        const SizedBox(height: 8),
        _field(
          controller: _phoneCtrl,
          hint: '55 0000 0000',
          icon: Icons.phone_outlined,
          colorScheme: colorScheme,
          onChanged: provider.onPhoneChange,
          errorText: provider.fieldErrors['phone'],
          type: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        _label(context, 'Fecha de nacimiento', colorScheme,
            hasError: provider.fieldErrors['birthdate'] != null),
        const SizedBox(height: 8),
        _buildDriverDateField(context, provider, colorScheme),
        const SizedBox(height: 16),
        _label(context, 'Contraseña', colorScheme,
            hasError: provider.fieldErrors['password'] != null),
        const SizedBox(height: 8),
        _field(
          controller: _passCtrl,
          hint: 'Mín. 8 caracteres',
          icon: Icons.lock_outline,
          colorScheme: colorScheme,
          obscure: _obscurePass,
          onChanged: provider.onPasswordChange,
          maxLength: 15,
          errorText: provider.fieldErrors['password'],
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
        const SizedBox(height: 16),
        _label(context, 'Confirmar contraseña', colorScheme,
            hasError: provider.fieldErrors['confirm'] != null),
        const SizedBox(height: 8),
        _field(
          controller: _confirmCtrl,
          hint: 'Repite tu contraseña',
          icon: Icons.lock_outline,
          colorScheme: colorScheme,
          obscure: _obscureConfirm,
          onChanged: provider.onConfirmPasswordChange,
          maxLength: 15,
          errorText: provider.fieldErrors['confirm'],
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        _errorWidget(provider, colorScheme),
      ],
    );
  }

  Widget _buildStep2(BuildContext context, RegisterDriverProvider provider,
      ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verificación requerida',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFBF360C),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sube tus documentos para que podamos validar tu perfil como conductor.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFBF360C),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _UploadDocCard(
          label: 'Identificación Oficial (INE)',
          hint: 'Tomar foto',
          required: true,
          imagePath: provider.docId,
          colorScheme: colorScheme,
          onTap: () => provider.pickDocId(ImageSource.camera),
        ),
        const SizedBox(height: 16),
        _UploadDocCard(
          label: 'Licencia de Conducir (vigente)',
          hint: 'Tomar foto',
          required: true,
          imagePath: provider.docLicense,
          colorScheme: colorScheme,
          onTap: () => provider.pickDocLicense(ImageSource.camera),
        ),
        const SizedBox(height: 16),
        _UploadDocCard(
          label: 'Comprobante de Domicilio',
          hint: 'Tomar foto',
          required: false,
          imagePath: provider.docAddressProof,
          colorScheme: colorScheme,
          onTap: () => provider.pickDocAddressProof(ImageSource.camera),
        ),
        _errorWidget(provider, colorScheme),
      ],
    );
  }

  Widget _buildStep3(BuildContext context, RegisterDriverProvider provider,
      ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registra tu primer vehículo',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Necesitas al menos un vehículo para empezar a enviar propuestas. Será revisado junto con tu perfil.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _labelRequired(context, 'Marca', colorScheme),
        const SizedBox(height: 8),
        _field(
          controller: _brandCtrl,
          hint: 'Ford, Chevrolet...',
          icon: Icons.directions_car_outlined,
          colorScheme: colorScheme,
          maxLength: 15,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ,]'))
          ],
          onChanged: provider.onBrandChange,
        ),
        const SizedBox(height: 16),
        _labelRequired(context, 'Modelo', colorScheme),
        const SizedBox(height: 8),
        _field(
          controller: _modelCtrl,
          hint: 'Silverado',
          icon: Icons.directions_car_outlined,
          colorScheme: colorScheme,
          maxLength: 15,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ,]'))
          ],
          onChanged: provider.onVehicleModelChange,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labelRequired(context, 'Año', colorScheme),
                  const SizedBox(height: 8),
                  _field(
                    controller: _yearCtrl,
                    hint: '2020',
                    icon: Icons.calendar_today_outlined,
                    colorScheme: colorScheme,
                    type: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: provider.onYearChange,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labelRequired(context, 'Color', colorScheme),
                  const SizedBox(height: 8),
                  _field(
                    controller: _colorCtrl,
                    hint: 'Blanco, Rojo...',
                    icon: Icons.palette_outlined,
                    colorScheme: colorScheme,
                    maxLength: 15,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ,]'))
                    ],
                    onChanged: provider.onColorChange,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _labelRequired(context, 'Placas', colorScheme),
        const SizedBox(height: 8),
        _field(
          controller: _plateCtrl,
          hint: 'ABC-1234',
          icon: Icons.tag,
          colorScheme: colorScheme,
          type: TextInputType.text,
          maxLength: 8,
          inputFormatters: [_PlateFormatter()],
          onChanged: (v) => provider.onPlateChange(_plateCtrl.text),
        ),
        const SizedBox(height: 16),
        _labelRequired(context, 'Capacidad de Carga', colorScheme),
        const SizedBox(height: 8),
        _field(
          controller: _capacityCtrl,
          hint: 'Ej. 1000 kg',
          icon: Icons.fitness_center_outlined,
          colorScheme: colorScheme,
          type: TextInputType.number,
          maxLength: 15,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: provider.onMaxCapacityChange,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Fotos del vehículo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
                Text(' *', style: TextStyle(color: colorScheme.error)),
              ],
            ),
            Text(
              '${provider.vehiclePhotosCount}/4 subidas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: Responsive.gridColumns(context),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
          children: [
            _VehicleImageTile(
              label: 'Vista lateral',
              description: 'Foto completa del lado del vehículo',
              imagePath: provider.imgVehicleSide,
              colorScheme: colorScheme,
              onTap: () => provider.pickImgVehicleSide(ImageSource.camera),
            ),
            _VehicleImageTile(
              label: 'Vista frontal',
              description: 'Foto de frente del vehículo',
              imagePath: provider.imgVehicleFront,
              colorScheme: colorScheme,
              onTap: () => provider.pickImgVehicleFront(ImageSource.camera),
            ),
            _VehicleImageTile(
              label: 'Área de carga',
              description: 'Interior o plataforma donde va la carga',
              imagePath: provider.imgCargoSpace,
              colorScheme: colorScheme,
              onTap: () => provider.pickImgCargoSpace(ImageSource.camera),
            ),
            _VehicleImageTile(
              label: 'Placas',
              description: 'Foto legible de las placas del vehículo',
              imagePath: provider.imgVehiclePlate,
              colorScheme: colorScheme,
              onTap: () => provider.pickImgVehiclePlate(ImageSource.camera),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Se requieren las 4 fotos para enviar el vehículo a revisión.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        _DriverLegalCheckboxes(provider: provider, colorScheme: colorScheme),
        _errorWidget(provider, colorScheme),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context,
      RegisterDriverProvider provider, ColorScheme colorScheme) {
    final isLastStep = provider.currentStep == 2;
    return Container(
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
                  provider.isLoading ? null : () => provider.prevStep(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Atrás'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed:
                  provider.isLoading ? null : () => provider.nextStep(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: provider.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colorScheme.onPrimary),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'Finalizar Registro' : 'Continuar',
                          style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward,
                            size: 18, color: colorScheme.onPrimary),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelRequired(
      BuildContext context, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(' *', style: TextStyle(color: colorScheme.error, fontSize: 12)),
      ],
    );
  }

  String _stepSubtitle(int step) {
    switch (step) {
      case 1:
        return 'Documentos requeridos';
      case 2:
        return 'Datos del vehículo';
      default:
        return 'Completa tus datos';
    }
  }

  Widget _label(BuildContext context, String text, ColorScheme colorScheme,
      {bool hasError = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface, fontWeight: FontWeight.w500),
        children: hasError
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: colorScheme.error, fontWeight: FontWeight.bold),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    required void Function(String) onChanged,
    TextInputType? type,
    bool obscure = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? errorText,
  }) {
    final hasError = errorText != null;
    final formatters = <TextInputFormatter>[
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ...?inputFormatters,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: type,
          obscureText: obscure,
          onChanged: onChanged,
          inputFormatters: formatters.isEmpty ? null : formatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            prefixIcon: Icon(icon,
                color: hasError
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: hasError
                ? colorScheme.errorContainer.withAlpha(60)
                : colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? BorderSide(color: colorScheme.error)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? BorderSide(color: colorScheme.error)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: hasError ? colorScheme.error : colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            counterText: '',
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(errorText,
              style: TextStyle(color: colorScheme.error, fontSize: 11)),
        ],
      ],
    );
  }

  Widget _buildDriverPhotoField(BuildContext context,
      RegisterDriverProvider provider, ColorScheme colorScheme) {
    return Center(
      child: GestureDetector(
        onTap: provider.pickProfilePhoto,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.surfaceContainer,
              backgroundImage: provider.profileImagePath != null
                  ? FileImage(File(provider.profileImagePath!))
                  : null,
              child: provider.profileImagePath == null
                  ? Icon(Icons.person,
                      size: 48, color: colorScheme.onSurfaceVariant)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: Icon(Icons.camera_alt,
                    size: 16, color: colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDateField(BuildContext context,
      RegisterDriverProvider provider, ColorScheme colorScheme) {
    final hasError = provider.fieldErrors['birthdate'] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _birthdateCtrl,
          readOnly: true,
          onTap: () async {
            final now = DateTime.now();
            final maxDate = DateTime(now.year - 18, now.month, now.day);
            final picked = await showDatePicker(
              context: context,
              initialDate: maxDate,
              firstDate: DateTime(now.year - 100),
              lastDate: maxDate,
            );
            if (picked != null) {
              _birthdateCtrl.text =
                  '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
              provider.onBirthdateChange(
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
              );
            }
          },
          decoration: InputDecoration(
            hintText: 'DD/MM/AAAA',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            prefixIcon: Icon(Icons.calendar_today_outlined,
                color: hasError
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: hasError
                ? colorScheme.errorContainer.withAlpha(60)
                : colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? BorderSide(color: colorScheme.error)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? BorderSide(color: colorScheme.error)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: hasError ? colorScheme.error : colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(provider.fieldErrors['birthdate']!,
              style: TextStyle(color: colorScheme.error, fontSize: 11)),
        ],
      ],
    );
  }

  Widget _errorWidget(
      RegisterDriverProvider provider, ColorScheme colorScheme) {
    if (provider.error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        provider.error!,
        style: TextStyle(color: colorScheme.error, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StepTabs extends StatelessWidget {
  final int currentStep;
  const _StepTabs({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeLabels = ['1.Tus Datos', '2.Documentos', '3.Tu Vehículo'];
    final doneLabels = ['Tus Datos', 'Documentos', 'Tu Vehículo'];

    return Row(
      children: List.generate(3, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isDone) ...[
                      Icon(Icons.check_circle,
                          size: 14, color: colorScheme.primary),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        isDone ? doneLabels[i] : activeLabels[i],
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: (isActive || isDone)
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 2,
                color: isActive
                    ? colorScheme.primary
                    : isDone
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _UploadDocCard extends StatelessWidget {
  final String label;
  final String hint;
  final bool required;
  final String? imagePath;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _UploadDocCard({
    required this.label,
    required this.hint,
    required this.required,
    required this.imagePath,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imagePath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
            ),
            if (required)
              Text(' *',
                  style: TextStyle(color: colorScheme.error, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: hasImage
                  ? Border.all(color: colorScheme.primary, width: 1.5)
                  : Border.all(color: colorScheme.outlineVariant, width: 1),
            ),
            child: hasImage
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(imagePath!),
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: colorScheme.primary,
                          child: Icon(Icons.check,
                              size: 14, color: colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload,
                          size: 32, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(
                        hint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _VehicleImageTile extends StatelessWidget {
  final String label;
  final String description;
  final String? imagePath;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _VehicleImageTile({
    required this.label,
    required this.description,
    required this.imagePath,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imagePath != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: hasImage
              ? Border.all(color: colorScheme.primary, width: 1.5)
              : Border.all(color: colorScheme.outlineVariant, width: 1),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(imagePath!), fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: colorScheme.primary,
                      child: Icon(Icons.check,
                          size: 12, color: colorScheme.onPrimary),
                    ),
                  ),
                ],
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload,
                        color: colorScheme.onSurfaceVariant, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DriverLegalCheckboxes extends StatelessWidget {
  final RegisterDriverProvider provider;
  final ColorScheme colorScheme;

  const _DriverLegalCheckboxes(
      {required this.provider, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DriverCheckRow(
          value: provider.acceptedTerms,
          onChanged: (_) => provider.toggleTerms(),
          colorScheme: colorScheme,
          text: 'Acepto los ',
          linkText: 'Términos y condiciones',
          onLinkTap: () => Navigator.pushNamed(context, AppRoutes.terms),
        ),
        const SizedBox(height: 8),
        _DriverCheckRow(
          value: provider.acceptedPrivacy,
          onChanged: (_) => provider.togglePrivacy(),
          colorScheme: colorScheme,
          text: 'Acepto la ',
          linkText: 'Política de privacidad',
          onLinkTap: () =>
              Navigator.pushNamed(context, AppRoutes.privacyPolicy),
        ),
      ],
    );
  }
}

class _DriverCheckRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final ColorScheme colorScheme;
  final String text;
  final String linkText;
  final VoidCallback onLinkTap;

  const _DriverCheckRow({
    required this.value,
    required this.onChanged,
    required this.colorScheme,
    required this.text,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            text: TextSpan(
              text: text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              children: [
                TextSpan(
                  text: linkText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                  recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlateFormatter extends TextInputFormatter {
  static final _validLetter = RegExp(r'[A-HJ-NPR-Z]');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final upper = newValue.text.toUpperCase();
    final buffer = StringBuffer();
    int letterCount = 0;
    int digitCount = 0;

    for (final ch in upper.runes.map(String.fromCharCode)) {
      if (letterCount < 3) {
        if (_validLetter.hasMatch(ch)) {
          buffer.write(ch);
          letterCount++;
          if (letterCount == 3) buffer.write('-');
        }
      } else if (digitCount < 4) {
        if (RegExp(r'[0-9]').hasMatch(ch)) {
          buffer.write(ch);
          digitCount++;
        }
      }
    }

    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
