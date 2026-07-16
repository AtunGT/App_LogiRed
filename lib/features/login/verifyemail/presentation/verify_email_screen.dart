import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined,
                  size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Verifica tu correo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Te enviamos un enlace de verificación a $email.\nRevisa tu bandeja de entrada.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false),
                child: const Text('Ir al login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
