import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';
import '../../shared/models/user_model.dart';
import '../welcome/welcome_page.dart';
import 'widgets/event_card.dart';

class LoggedUserHomePage extends StatelessWidget {
  final UserModel user;

  const LoggedUserHomePage({super.key, required this.user});

  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          // Ensure content avoids notches
          bottom: false,
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Olá,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () => _handleLogout(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Body (White curved sheet)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC), // Slate 50
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                          child: Text(
                            'Próximos Eventos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 24),
                            children: const [
                              EventCard(
                                title: 'Inteligência Artificial Generativa',
                                type: 'Palestra',
                                time: '09:00 - 10:30',
                                speaker: 'Dra. Ana Silva',
                                location: 'Auditório A',
                              ),
                              EventCard(
                                title: 'Desenvolvimento Mobile com Flutter',
                                type: 'Workshop',
                                time: '11:00 - 12:30',
                                speaker: 'Pedro Alcantara',
                                location: 'Lab 3',
                              ),
                              EventCard(
                                title: 'O Futuro da Cibersegurança',
                                type: 'Palestra',
                                time: '14:00 - 15:30',
                                speaker: 'Carlos Santos',
                                location: 'Auditório B',
                              ),
                              EventCard(
                                title: 'Blockchain na Prática',
                                type: 'Workshop',
                                time: '16:00 - 18:00',
                                speaker: 'Marcos Oliveira',
                                location: 'Lab 2',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
