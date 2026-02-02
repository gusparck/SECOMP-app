import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          // Ensure content avoids notches
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                // Hero Section
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Semana da Computação',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  '2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color:
                        Colors.white, // Maybe accent color? Kept white for now.
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'O maior evento de tecnologia da região.\nConecte-se, aprenda e inove.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const Spacer(flex: 4),
                // Actions
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Já tenho conta'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Criar conta'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
