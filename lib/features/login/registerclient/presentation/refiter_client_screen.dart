import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../domain/repository/register_client_repository.dart';
import '../../../../core/routes/app_routes.dart';
import 'register_client_provider.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _birthdateCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (c) => RegisterClientProvider(c.read<RegisterClientRepository>()),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: SafeArea(
          child: Consumer<RegisterClientProvider>(
            builder: (context, provider, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (provider.registerSuccess) {
                  Navigator.pushReplacementNamed(context, '/verify-email',
                      arguments: provider.email);
                }
              });

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        'Completa tus datos',
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
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, top: 16, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tus Datos',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Divider(
                                      color: colorScheme.primary,
                                      thickness: 2,
                                      height: 1),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPhotoField(
                                      context, provider, colorScheme),
                                  if (provider.fieldErrors['photo'] !=
                                      null) ...[
                                    const SizedBox(height: 6),
                                    Center(
                                      child: Text(
                                        provider.fieldErrors['photo']!,
                                        style: TextStyle(
                                            color: colorScheme.error,
                                            fontSize: 11),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  _buildLabel(context, 'Nombre(s)', colorScheme,
                                      hasError:
                                          provider.fieldErrors['name'] != null),
                                  const SizedBox(height: 8),
                                  _buildField(
                                    controller: _nameCtrl,
                                    hint: 'Tu nombre',
                                    icon: Icons.person_outline,
                                    colorScheme: colorScheme,
                                    onChanged: provider.onNameChange,
                                    errorText: provider.fieldErrors['name'],
                                    maxLength: 50,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ,]')),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLabel(
                                      context, 'Apellido(s)', colorScheme,
                                      hasError:
                                          provider.fieldErrors['lastname'] !=
                                              null),
                                  const SizedBox(height: 8),
                                  _buildField(
                                    controller: _lastNameCtrl,
                                    hint: 'Tu apellido',
                                    icon: Icons.person_outline,
                                    colorScheme: colorScheme,
                                    onChanged: provider.onLastnameChange,
                                    errorText: provider.fieldErrors['lastname'],
                                    maxLength: 40,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ,]')),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLabel(context, 'Correo electrónico',
                                      colorScheme,
                                      hasError: provider.fieldErrors['email'] !=
                                          null),
                                  const SizedBox(height: 8),
                                  _buildField(
                                    controller: _emailCtrl,
                                    hint: 'tu@correo.com',
                                    icon: Icons.mail_outline,
                                    colorScheme: colorScheme,
                                    type: TextInputType.emailAddress,
                                    onChanged: provider.onEmailChange,
                                    errorText: provider.fieldErrors['email'],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLabel(context, 'Teléfono', colorScheme,
                                      hasError: provider.fieldErrors['phone'] !=
                                          null),
                                  const SizedBox(height: 8),
                                  _buildField(
                                    controller: _phoneCtrl,
                                    hint: '55 0000 0000',
                                    icon: Icons.phone_outlined,
                                    colorScheme: colorScheme,
                                    onChanged: provider.onPhoneChange,
                                    errorText: provider.fieldErrors['phone'],
                                    type: TextInputType.number,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLabel(context, 'Fecha de nacimiento',
                                      colorScheme,
                                      hasError:
                                          provider.fieldErrors['birthdate'] !=
                                              null),
                                  const SizedBox(height: 8),
                                  _buildDateField(
                                      context, provider, colorScheme),
                                  const SizedBox(height: 16),
                                  _buildLabel(
                                      context, 'Contraseña', colorScheme,
                                      hasError:
                                          provider.fieldErrors['password'] !=
                                              null),
                                  const SizedBox(height: 8),
                                  _buildField(
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
                                      onPressed: () => setState(
                                          () => _obscurePass = !_obscurePass),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLabel(context, 'Confirmar contraseña',
                                      colorScheme,
                                      hasError:
                                          provider.fieldErrors['confirm'] !=
                                              null),
                                  const SizedBox(height: 8),
                                  _buildField(
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
                                      onPressed: () => setState(() =>
                                          _obscureConfirm = !_obscureConfirm),
                                    ),
                                  ),
                                  if (provider.error != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      provider.error!,
                                      style: TextStyle(
                                          color: colorScheme.error,
                                          fontSize: 13),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _LegalCheckboxes(
                          provider: provider, colorScheme: colorScheme),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Atrás'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.onSurface,
                                side: BorderSide(color: colorScheme.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed:
                                  provider.isLoading ? null : provider.register,
                              icon: provider.isLoading
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.onPrimary,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              label: provider.isLoading
                                  ? const SizedBox.shrink()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Crear Cuenta',
                                          style: TextStyle(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.arrow_forward,
                                            size: 18,
                                            color: colorScheme.onPrimary),
                                      ],
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text, ColorScheme colorScheme,
      {bool hasError = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    required void Function(String) onChanged,
    TextInputType? type,
    bool obscure = false,
    Widget? suffixIcon,
    int? maxLength,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final hasError = errorText != null;
    final formatters = <TextInputFormatter>[
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      if (inputFormatters != null) ...inputFormatters,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: type,
          obscureText: obscure,
          onChanged: onChanged,
          maxLength: maxLength,
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
          Text(
            errorText,
            style: TextStyle(color: colorScheme.error, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoField(BuildContext context, RegisterClientProvider provider,
      ColorScheme colorScheme) {
    return Center(
      child: GestureDetector(
        onTap: provider.pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.surfaceContainer,
              backgroundImage: provider.imagePath != null
                  ? FileImage(File(provider.imagePath!))
                  : null,
              child: provider.imagePath == null
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
                  border: Border.all(
                      color: colorScheme.surfaceContainerLowest, width: 2),
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

  Widget _buildDateField(BuildContext context, RegisterClientProvider provider,
      ColorScheme colorScheme) {
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
}

class _LegalCheckboxes extends StatelessWidget {
  final RegisterClientProvider provider;
  final ColorScheme colorScheme;

  const _LegalCheckboxes({required this.provider, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CheckRow(
          value: provider.acceptedTerms,
          onChanged: (_) => provider.toggleTerms(),
          colorScheme: colorScheme,
          text: 'Acepto los ',
          linkText: 'Términos y condiciones',
          onLinkTap: () => Navigator.pushNamed(context, AppRoutes.terms),
        ),
        const SizedBox(height: 8),
        _CheckRow(
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

class _CheckRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final ColorScheme colorScheme;
  final String text;
  final String linkText;
  final VoidCallback onLinkTap;

  const _CheckRow({
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
