import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';
import '../../shared/models/user_model.dart';
import '../events/event_service.dart';
import '../events/event_create_page.dart';
import '../events/event_details_page.dart';
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
      floatingActionButton: user.role == Role.ADMIN
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to create event page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventCreatePage()),
                );
              },
              backgroundColor: const Color(0xFF1E3C72),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: GradientBackground(
        child: SafeArea(
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
                          child: ListenableBuilder(
                            listenable: EventService(),
                            builder: (context, child) {
                              final events = EventService().events;
                              if (events.isEmpty) {
                                return const Center(
                                  child: Text('Nenhum evento encontrado'),
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return EventCard(
                                    event: event,
                                    onTap: () {
                                      // Navigate to details
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EventDetailsPage(event: event),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
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
