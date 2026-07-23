import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';

/// Recuperación de contraseña con código por correo (flujo 100% en la app).
///
/// El backend genera un código de 6 dígitos, lo envía por correo y, al
/// verificarlo, actualiza la contraseña en la BD y en Firebase Auth a la vez.
/// La app solo llama dos endpoints:
/// - POST /users/password-reset/request  {email}
/// - PUT  /users/password-reset          {email, code, newPassword}
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _Step { email, code, done }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  _Step _step = _Step.email;
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String get _email => _emailCtrl.text.trim();

  Future<void> _requestCode() async {
    if (_email.isEmpty || !_email.contains('@')) {
      setState(() => _error = 'Escribe un correo válido');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await context
          .read<ApiService>()
          .requestPasswordResetCode({'email': _email});
      _codeCtrl.clear();
      _passCtrl.clear();
      setState(() => _step = _Step.code);
    } on DioException catch (e) {
      setState(() => _error = _requestError(e));
    } catch (_) {
      setState(() => _error = 'No se pudo enviar el código. Intenta de nuevo');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _requestError(DioException e) {
    if (e.response == null) return 'Conéctate a internet e intenta de nuevo';
    switch (e.response!.statusCode) {
      case 404:
        return 'Este correo no está registrado';
      case 429:
        return 'Pediste demasiados códigos. Espera unos minutos e intenta de nuevo';
      default:
        return 'No se pudo enviar el código. Intenta de nuevo';
    }
  }

  Future<void> _submitNewPassword() async {
    final code = _codeCtrl.text.trim();
    final pass = _passCtrl.text;
    if (code.length != 6) {
      setState(() => _error = 'Escribe el código de 6 dígitos del correo');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await context.read<ApiService>().resetPassword({
        'email': _email,
        'code': code,
        'newPassword': pass,
      });
      setState(() => _step = _Step.done);
    } on DioException catch (e) {
      setState(() => _error = _resetError(e));
    } catch (_) {
      setState(
          () => _error = 'No se pudo actualizar la contraseña. Intenta de nuevo');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _resetError(DioException e) {
    if (e.response == null) return 'Conéctate a internet e intenta de nuevo';
    switch (e.response!.statusCode) {
      case 400:
        return 'Código inválido o expirado. Revísalo o pide uno nuevo';
      case 429:
        return 'Demasiados intentos. Pide un código nuevo y espera unos minutos';
      default:
        return 'No se pudo actualizar la contraseña. Intenta de nuevo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        title: const Text('Recuperar contraseña',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: switch (_step) {
            _Step.email => _buildEmailStep(colorScheme),
            _Step.code => _buildCodeStep(colorScheme),
            _Step.done => _buildDoneStep(colorScheme),
          },
        ),
      ),
    );
  }

  Widget _buildEmailStep(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Icon(Icons.lock_reset, size: 72, color: cs.primary),
        const SizedBox(height: 20),
        const Text(
          'Escribe tu correo y te enviaremos un código de 6 dígitos para cambiar tu contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => setState(() => _error = null),
          decoration: _fieldDecoration(cs,
              hint: 'tucorreo@ejemplo.com', icon: Icons.email_outlined),
        ),
        if (_error != null) _errorText(cs),
        const SizedBox(height: 24),
        _primaryButton(cs, label: 'Enviar código', onPressed: _requestCode),
      ],
    );
  }

  Widget _buildCodeStep(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Icon(Icons.mark_email_read_outlined, size: 64, color: cs.primary),
        const SizedBox(height: 16),
        Text(
          'Te enviamos un código a\n$_email',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Revisa tu correo y escribe el código de 6 dígitos junto con tu nueva contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() => _error = null),
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••••',
            hintStyle: TextStyle(
                color: cs.onSurfaceVariant, letterSpacing: 8, fontSize: 24),
            filled: true,
            fillColor: cs.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure,
          onChanged: (_) => setState(() => _error = null),
          decoration: InputDecoration(
            hintText: 'Tu nueva contraseña',
            prefixIcon: Icon(Icons.lock_outline, color: cs.onSurfaceVariant),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: cs.onSurfaceVariant,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            filled: true,
            fillColor: cs.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_error != null) _errorText(cs),
        const SizedBox(height: 20),
        _primaryButton(cs,
            label: 'Cambiar contraseña', onPressed: _submitNewPassword),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _isLoading ? null : _requestCode,
          child: const Text('Reenviar código'),
        ),
      ],
    );
  }

  Widget _buildDoneStep(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.check_circle_rounded, size: 80, color: cs.primary),
        const SizedBox(height: 20),
        const Text(
          '¡Contraseña actualizada!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ya puedes iniciar sesión con tu nueva contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 28),
        _primaryButton(cs,
            label: 'Volver al login',
            onPressed: () => Navigator.pop(context),
            showSpinner: false),
      ],
    );
  }

  // ---- Helpers de UI ----

  InputDecoration _fieldDecoration(ColorScheme cs,
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
      filled: true,
      fillColor: cs.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _errorText(ColorScheme cs) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(_error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.error, fontSize: 13)),
      );

  Widget _primaryButton(ColorScheme cs,
      {required String label,
      required VoidCallback onPressed,
      bool showSpinner = true}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading && showSpinner
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: cs.onPrimary))
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
