import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registre-se')),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: const Text('Entrar')),
            ],
          ),
        ),
      ),
    );
  }
}
