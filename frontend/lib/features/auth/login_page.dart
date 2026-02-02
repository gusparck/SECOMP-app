import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';
import '../../core/ui/widgets/auth_card.dart';
import '../../core/ui/widgets/custom_text_field.dart';
import '../home/logged_user_home_page.dart';
import 'auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoggedUserHomePage(user: user)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha no login. Verifique suas credenciais.'),
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthCard(
                  title: 'Bem-vindo de volta!',
                  subtitle: 'Acesse sua conta para continuar',
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || !v.contains('@')
                              ? 'Email inválido'
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        CustomTextFormField(
                          controller: _passwordController,
                          label: 'Senha',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Informe sua senha'
                              : null,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {}, // TODO: Forgot Password
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shadowColor: Colors.indigo.withOpacity(0.4),
                                    elevation: 8,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Entrar'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _navigateToRegister,
                  child: RichText(
                    text: const TextSpan(
                      text: 'Não tem uma conta? ',
                      style: TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: 'Cadastre-se',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
