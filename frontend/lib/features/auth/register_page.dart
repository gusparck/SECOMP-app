import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

  String? _selectedCampus;
  double _passwordStrength = 0.0;

  final _registrationMask = MaskTextInputFormatter(
    mask: '##.#.####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _authService = AuthService();
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};

  void _clearError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() {
        _fieldErrors.remove(field);
      });
    }
  }

  void _updatePasswordStrength(String password) {
    double strength = 0.0;
    if (password.isEmpty) {
      strength = 0.0;
    } else {
      if (password.length >= 8) strength += 0.2;
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
      if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    }
    setState(() {
      _passwordStrength = strength;
    });
    _clearError('password');
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _fieldErrors.clear();
    });

    try {
      final user = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        registration: _registrationController.text.trim(),
        course: _courseController.text.trim().isEmpty
            ? null
            : _courseController.text.trim(),
        campus: _selectedCampus,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoggedUserHomePage(user: user)),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          if (e.errors != null) {
            _fieldErrors = e.errors!;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: AuthCard(
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
                            errorText: _fieldErrors['name'],
                            onChanged: (_) => _clearError('name'),
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
                            errorText: _fieldErrors['email'],
                            onChanged: (_) => _clearError('email'),
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
                            keyboardType:
                                TextInputType.number, // Mask handles validation
                            inputFormatters: [_registrationMask],
                            errorText: _fieldErrors['registration'],
                            onChanged: (_) => _clearError('registration'),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Informe sua matrícula';
                              if (_registrationMask.getUnmaskedText().length <
                                  7) return 'Matrícula incompleta';
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: _passwordController,
                            label: 'Senha',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            errorText: _fieldErrors['password'],
                            onChanged: (value) {
                              _updatePasswordStrength(value);
                              _clearError('password');
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Informe uma senha';
                              if (_passwordStrength < 1.0)
                                return 'Senha deve ter maiúscula, minúscula, número e especial';
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          if (_passwordController.text.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: _passwordStrength,
                                    backgroundColor: Colors.grey[300],
                                    color: _passwordStrength < 0.4
                                        ? Colors.red
                                        : _passwordStrength < 0.8
                                            ? Colors.orange
                                            : Colors.green,
                                    minHeight: 5,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _passwordStrength < 0.4
                                        ? 'Fraca'
                                        : _passwordStrength < 0.8
                                            ? 'Média'
                                            : 'Forte',
                                    style: TextStyle(
                                      color: _passwordStrength < 0.4
                                          ? Colors.red
                                          : _passwordStrength < 0.8
                                              ? Colors.orange
                                              : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
                                  errorText: _fieldErrors['course'],
                                  onChanged: (_) => _clearError('course'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedCampus,
                                  decoration: InputDecoration(
                                    labelText: 'Campus (Opc)',
                                    prefixIcon: const Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF64748B)),
                                    filled: true,
                                    fillColor: const Color(0xFFF1F5F9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorText: _fieldErrors['campus'],
                                  ),
                                  items: [
                                    'Ouro Preto',
                                    'Mariana',
                                    'João Monlevade'
                                  ]
                                      .map((label) => DropdownMenuItem(
                                            value: label,
                                            child: Text(label),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCampus = value;
                                    });
                                    _clearError('campus');
                                  },
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
