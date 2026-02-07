import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';
import '../../core/ui/widgets/auth_card.dart';
import '../../core/ui/widgets/custom_text_field.dart';
import '../home/logged_user_home_page.dart';
import 'auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _registrationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _courseController = TextEditingController();
  final _campusController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = await _authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      registration: _registrationController.text.trim(),
      course: _courseController.text.trim().isEmpty
          ? null
          : _courseController.text.trim(),
      campus: _campusController.text.trim().isEmpty
          ? null
          : _campusController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoggedUserHomePage(user: user)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha no cadastro. Tente novamente.')),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
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
                  title: 'Crie sua conta',
                  subtitle: 'Preencha seus dados para começar',
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextFormField(
                          controller: _nameController,
                          label: 'Nome Completo',
                          icon: Icons.person_outline,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Informe seu nome'
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
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
                          controller: _registrationController,
                          label: 'Matrícula',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Informe sua matrícula'
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        CustomTextFormField(
                          controller: _passwordController,
                          label: 'Senha',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (v) => v == null || v.length < 6
                              ? 'Mínimo de 6 caracteres'
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextFormField(
                                controller: _courseController,
                                label: 'Curso (Opc)',
                                icon: Icons.school_outlined,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextFormField(
                                controller: _campusController,
                                label: 'Campus (Opc)',
                                icon: Icons.location_on_outlined,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleRegister(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _handleRegister,
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
                                child: const Text('Cadastrar'),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _navigateToLogin,
                  child: RichText(
                    text: const TextSpan(
                      text: 'Já tem uma conta? ',
                      style: TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: 'Entre',
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
