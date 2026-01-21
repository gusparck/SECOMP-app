import 'package:flutter/material.dart';
// import 'package:frontend/core/theme/extensions/app_colors.dart';
import '../../shared/layouts/public_layout.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';

class WelcomePage extends StatelessWidget {
  // final colors = Theme.of(context).extensions<AppColors>()!;
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      child: Column(
        children: [
          const Spacer(),
          // Icon(Icons.code, size: 80, color: colors.onBackground),
          Icon(Icons.code, size: 80, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            'Semana da Computação 2026',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Entrar'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('Cadastrar'),
            ),
          ),
        ],
      ),
    );
  }
}
