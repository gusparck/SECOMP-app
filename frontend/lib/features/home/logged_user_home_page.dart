import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';
import '../../shared/models/user_model.dart';
import '../events/event_service.dart';
import '../events/event_model.dart';
import '../events/event_details_page.dart';
import '../events/my_events_page.dart';
import '../events/my_tickets_page.dart';
import '../events/team_events_page.dart';
import '../profile/profile_page.dart';
import 'widgets/event_card.dart';

class LoggedUserHomePage extends StatefulWidget {
  final UserModel user;

  const LoggedUserHomePage({super.key, required this.user});

  @override
  State<LoggedUserHomePage> createState() => _LoggedUserHomePageState();
}

class _LoggedUserHomePageState extends State<LoggedUserHomePage> {
  final EventService _eventService = EventService();
  late Future<List<EventModel>> _eventsFuture;
  int _currentIndex = 0;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = _eventService.getEvents();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canManageEvents =
        widget.user.role == Role.ADMIN || widget.user.role == Role.PROFESSOR;

    final List<Widget> pages = [
      _buildEventsPage(),
      const MyTicketsPage(),
      const TeamEventsPage(),
      if (canManageEvents) const MyEventsPage(),
      ProfilePage(user: widget.user),
    ];

    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today, color: Colors.indigo),
        label: 'Eventos',
      ),
      const NavigationDestination(
        icon: Icon(Icons.confirmation_number_outlined),
        selectedIcon: Icon(Icons.confirmation_number, color: Colors.indigo),
        label: 'Ingressos',
      ),
      const NavigationDestination(
        icon: Icon(Icons.badge_outlined),
        selectedIcon: Icon(Icons.badge, color: Colors.indigo),
        label: 'Equipe',
      ),
      if (canManageEvents)
        const NavigationDestination(
          icon: Icon(Icons.edit_calendar_outlined),
          selectedIcon: Icon(Icons.edit_calendar, color: Colors.indigo),
          label: 'Gerenciar',
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: Colors.indigo),
        label: 'Perfil',
      ),
    ];

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
            return;
          }
          final now = DateTime.now();
          if (_lastPressedAt == null ||
              now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
            _lastPressedAt = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pressione novamente para sair do app'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            // Exits app
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Theme.of(context).colorScheme.primaryContainer,
              labelTextStyle: MaterialStateProperty.all(
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 3,
              destinations: destinations,
            ),
          ),
        ));
  }

  Widget _buildEventsPage() {
    return GradientBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bem-vindo,",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        widget.user.name.split(' ')[0], // First name
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: FutureBuilder<List<EventModel>>(
                    future: _eventsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Nenhum evento encontrado.'));
                      }

                      final events = snapshot.data!;

                      return RefreshIndicator(
                        onRefresh: () async => _loadEvents(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: EventCard(
                                event: event,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailsPage(event: event),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
