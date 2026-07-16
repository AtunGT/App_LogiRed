import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../../core/utils/responsive.dart';
import '../domain/model/login_result.dart';
import 'login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _preventScreenshotOn();
  }

  Future<void> _preventScreenshotOn() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      debugPrint('Error enabling screenshot prevention: $e');
    }
  }

  Future<void> _preventScreenshotOff() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      debugPrint('Error disabling screenshot prevention: $e');
    }
  }

  @override
  void dispose() {
    _preventScreenshotOff();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: SafeArea(
          child: Consumer<LoginProvider>(
            builder: (context, provider, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (provider.result is LoginSuccess) {
                  final success = provider.result as LoginSuccess;
                  TextInput.finishAutofillContext();
                  if (success.userType == 2) {
                    Navigator.pushReplacementNamed(context, '/driver-main');
                  } else {
                    Navigator.pushReplacementNamed(context, '/client-main');
                  }
                }
              });

              final isTabletLandscape = Responsive.isTablet(context) &&
                  Responsive.isLandscape(context);

              if (isTabletLandscape) {
                return _TabletLandscapeLayout(
                  provider: provider,
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  colorScheme: colorScheme,
                );
              }

              return _PortraitLayout(
                provider: provider,
                emailCtrl: _emailCtrl,
                passCtrl: _passCtrl,
                obscure: _obscure,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
                colorScheme: colorScheme,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  final LoginProvider provider;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ColorScheme colorScheme;

  const _PortraitLayout({
    required this.provider,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final maxW = Responsive.maxContentWidth(context);

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 52),
          Image.asset('assets/images/logo.png', height: 80),
          const SizedBox(height: 20),
          Text(
            'Iniciar Sesión',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bienvenido de vuelta',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          _LoginForm(
            provider: provider,
            emailCtrl: emailCtrl,
            passCtrl: passCtrl,
            obscure: obscure,
            onToggleObscure: onToggleObscure,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 24),
          _RegisterLink(colorScheme: colorScheme),
          const SizedBox(height: 32),
        ],
      ),
    );

    if (maxW != double.infinity) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _TabletLandscapeLayout extends StatelessWidget {
  final LoginProvider provider;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ColorScheme colorScheme;

  const _TabletLandscapeLayout({
    required this.provider,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: colorScheme.primaryContainer,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 80),
                    const SizedBox(height: 24),
                    Text(
                      'LogiRed',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Conectando conductores\ncon clientes',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Iniciar Sesión',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bienvenido de vuelta',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 28),
                    _LoginForm(
                      provider: provider,
                      emailCtrl: emailCtrl,
                      passCtrl: passCtrl,
                      obscure: obscure,
                      onToggleObscure: onToggleObscure,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 20),
                    _RegisterLink(colorScheme: colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  final LoginProvider provider;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ColorScheme colorScheme;

  const _LoginForm({
    required this.provider,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correo electrónico',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              onChanged: provider.onEmailChange,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email
              ],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'tu@correo.com',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.mail_outline,
                    color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Contraseña',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passCtrl,
              obscureText: obscure,
              onChanged: provider.onPasswordChange,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!provider.isLoading) provider.login();
              },
              decoration: InputDecoration(
                hintText: 'Tu contraseña',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.lock_outline,
                    color: colorScheme.onSurfaceVariant),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onToggleObscure,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 12),
              Text(
                provider.error!,
                style: TextStyle(color: colorScheme.error, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : provider.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: provider.isLoading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'Iniciar Sesión',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: colorScheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o continúa con',
                    style: TextStyle(
                        fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ),
                Expanded(child: Divider(color: colorScheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed:
                    provider.isGoogleLoading ? null : provider.loginWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.surfaceContainerLowest,
                ),
                child: provider.isGoogleLoading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.primary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.g_mobiledata,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Iniciar sesión con Google',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  final ColorScheme colorScheme;
  const _RegisterLink({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta?  ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Regístrate aquí',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
